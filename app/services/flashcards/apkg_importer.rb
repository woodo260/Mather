require "sqlite3"
require "json"
require "nokogiri"
require "tmpdir"
require "open3"

module Flashcards
  # Imports a deck from an Anki package (.apkg / .colpkg).
  #
  # An .apkg is a zip archive containing an SQLite collection database plus media
  # files. We read the `notes` table: each note's `flds` column holds its fields
  # joined by the 0x1f unit separator. The first field becomes the card front and
  # the rest become the back. HTML/media markup is stripped down to plain text.
  #
  # Both the legacy schema (`collection.anki2`, decks stored as JSON in the `col`
  # table) and the newer schema (`collection.anki21`/`.anki21b`, decks in a
  # `decks` table, the `b` variant zstd-compressed) are supported.
  class ApkgImporter
    FIELD_SEPARATOR = "\x1f".freeze
    # Newest first: prefer the richest collection the package offers.
    DB_CANDIDATES = %w[collection.anki21b collection.anki21 collection.anki2].freeze
    ZSTD_MAGIC = "\x28\xB5\x2F\xFD".b.freeze

    def self.parse(path, filename: nil)
      new(path, filename).parse
    end

    def initialize(path, filename)
      @path = path
      @filename = filename
    end

    def parse
      Dir.mktmpdir("mather-apkg") do |dir|
        extract(dir)
        db = open_collection(locate_db(dir))
        begin
          cards = read_cards(db)
          raise ImportError, "No cards found in this Anki package." if cards.empty?
          ParsedDeck.new(name: deck_name(db), description: nil, cards: cards)
        ensure
          db.close
        end
      end
    end

    private

    def extract(dir)
      _output, status = Open3.capture2e("unzip", "-o", "-qq", @path, "-d", dir)
      return if status.success?

      raise ImportError, "That file isn't a readable Anki package (couldn't unzip it)."
    end

    def locate_db(dir)
      name = DB_CANDIDATES.find { |candidate| File.exist?(File.join(dir, candidate)) }
      raise ImportError, "This doesn't look like an Anki deck (no collection database inside)." unless name

      source = File.join(dir, name)
      return source unless zstd?(source)

      decompressed = File.join(dir, "collection.decompressed.anki2")
      decompress_zstd(source, decompressed)
      decompressed
    end

    def zstd?(file)
      File.binread(file, 4) == ZSTD_MAGIC
    end

    def decompress_zstd(source, dest)
      _output, status = Open3.capture2e("zstd", "-d", "-q", "-f", "-o", dest, source)
      return if status.success?

      raise ImportError,
        "Couldn't read this Anki package. Re-export it from Anki with " \
        "“Support older Anki versions” checked and try again."
    end

    def open_collection(db_path)
      SQLite3::Database.new(db_path, readonly: true)
    rescue SQLite3::Exception
      raise ImportError, "The Anki collection inside this package is corrupt or unreadable."
    end

    def read_cards(db)
      db.execute("SELECT flds FROM notes ORDER BY id").filter_map { |(flds)| note_to_card(flds) }
    rescue SQLite3::Exception
      raise ImportError, "Couldn't read the cards out of this Anki package."
    end

    def note_to_card(flds)
      return if flds.nil?

      fields = flds.split(FIELD_SEPARATOR).map { |field| clean(field) }.reject(&:blank?)
      return if fields.size < 2

      { front: fields.first, back: fields[1..].join("\n\n") }
    end

    # Reduce a note field (which may contain HTML and media references) to plain text.
    def clean(text)
      string = text.to_s.dup
      string.gsub!(/\[sound:[^\]]*\]/, " ")             # audio references
      string.gsub!(/<\s*br\s*\/?>/i, "\n")              # line breaks
      string.gsub!(/<\/(?:div|p|li|tr|h[1-6])>/i, "\n") # block ends
      # Nokogiri strips remaining tags and decodes HTML entities (&times;, &oacute;, …).
      string = Nokogiri::HTML.fragment(string).text
      string.gsub!(/ /, " ")                       # non-breaking spaces
      string.gsub!(/\r\n?/, "\n")
      string.gsub!(/[ \t]+/, " ")
      string.gsub!(/\n{3,}/, "\n\n")
      string.split("\n").map(&:strip).join("\n").strip
    end

    def deck_name(db)
      names = deck_id_to_name(db)
      counts = card_counts_by_deck(db)

      biggest = counts.max_by { |_deck_id, count| count }&.first
      name = names[biggest] || names.values.find { |n| n.present? && n != "Default" }
      name = name.split("::").first if name # root deck for subdecks like "Parent::Child"
      name.presence || fallback_name
    end

    def deck_id_to_name(db)
      if table?(db, "decks")
        db.execute("SELECT id, name FROM decks").to_h
      else
        json = db.get_first_value("SELECT decks FROM col")
        JSON.parse(json.to_s).to_h { |id, deck| [ id.to_i, deck["name"] ] }
      end
    rescue SQLite3::Exception, JSON::ParserError
      {}
    end

    def card_counts_by_deck(db)
      db.execute("SELECT did, COUNT(*) FROM cards GROUP BY did").to_h
    rescue SQLite3::Exception
      {}
    end

    def table?(db, name)
      db.get_first_value("SELECT 1 FROM sqlite_master WHERE type='table' AND name=?", name) == 1
    end

    def fallback_name
      base = File.basename(@filename.to_s, ".*").tr("_-", "  ").strip
      base.presence || "Imported deck"
    end
  end
end
