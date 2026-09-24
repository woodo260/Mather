module Flashcards
  # Turns an import source (uploaded file or AnkiWeb link) into a saved, session
  # owned Deck. Parsing lives in the per-format importers; this class handles
  # dispatch, upload guards, and persistence.
  class DeckImporter
    MAX_UPLOAD_BYTES = 100.megabytes
    INSERT_BATCH = 500

    def initialize(session_token:)
      @session_token = session_token
    end

    def import_file(upload)
      raise ImportError, "Choose a file to import." if upload.blank?
      if upload.size > MAX_UPLOAD_BYTES
        raise ImportError, "That file is too large to import (limit #{MAX_UPLOAD_BYTES / 1.megabyte} MB)."
      end

      persist(parse_upload(upload))
    end

    def import_from_ankiweb(input)
      file, filename = AnkiWeb.download(input)
      begin
        persist(ApkgImporter.parse(file.path, filename: filename))
      ensure
        file.close!
      end
    end

    private

    def parse_upload(upload)
      name = upload.original_filename.to_s.downcase

      if name.end_with?(".apkg", ".colpkg")
        ApkgImporter.parse(upload.tempfile.path, filename: upload.original_filename)
      elsif name.end_with?(".json")
        JsonImporter.parse(upload.read, filename: upload.original_filename)
      else
        parse_by_content(upload)
      end
    end

    # No recognizable extension: sniff the first bytes. A zip (Anki package)
    # starts with "PK"; anything else we treat as JSON.
    def parse_by_content(upload)
      if File.binread(upload.tempfile.path, 2) == "PK"
        ApkgImporter.parse(upload.tempfile.path, filename: upload.original_filename)
      else
        JsonImporter.parse(File.read(upload.tempfile.path), filename: upload.original_filename)
      end
    end

    def persist(parsed)
      deck = nil
      Deck.transaction do
        deck = Deck.create!(
          name:          parsed.name,
          description:   parsed.description,
          session_token: @session_token,
          builtin:       false
        )

        now = Time.current
        rows = parsed.cards.each_with_index.map do |card, index|
          { deck_id: deck.id, front: card[:front], back: card[:back], position: index, created_at: now, updated_at: now }
        end
        rows.each_slice(INSERT_BATCH) { |batch| Card.insert_all(batch) }
      end
      deck
    end
  end
end
