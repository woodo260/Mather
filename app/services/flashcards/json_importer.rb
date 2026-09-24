require "json"

module Flashcards
  # Imports a deck from a JSON file. Accepts a few shapes so hand-written files
  # and exports from other tools both work:
  #
  #   { "name": "...", "description": "...", "cards": [ { "front": "...", "back": "..." } ] }
  #   { "cards": [ ... ] }          # name taken from the filename
  #   [ { "front": "...", "back": "..." }, ... ]   # a bare list of cards
  #
  # Within each card, front/back may also be given as question/answer, q/a,
  # term/definition, or prompt/response.
  class JsonImporter
    FRONT_KEYS = %w[front question q term prompt].freeze
    BACK_KEYS  = %w[back answer a definition response].freeze

    def self.parse(raw, filename: nil)
      new(raw, filename).parse
    end

    def initialize(raw, filename)
      @raw = raw
      @filename = filename
    end

    def parse
      data = JSON.parse(@raw)

      name, description, cards_data =
        case data
        when Array then [ nil, nil, data ]
        when Hash  then [ data["name"] || data["title"], data["description"], data["cards"] || data["notes"] ]
        else raise ImportError, "The JSON must be a list of cards or an object with a \"cards\" list."
        end

      unless cards_data.is_a?(Array)
        raise ImportError, "The JSON needs a \"cards\" list (an array of { \"front\", \"back\" } objects)."
      end

      cards = cards_data.filter_map { |card| card_from(card) }
      if cards.empty?
        raise ImportError, "No usable cards found — each card needs both a front and a back."
      end

      ParsedDeck.new(name: name.presence || fallback_name, description: description.presence, cards: cards)
    rescue JSON::ParserError => e
      raise ImportError, "That file isn't valid JSON (#{e.message.truncate(120)})."
    end

    private

    def card_from(card)
      return unless card.is_a?(Hash)

      front = pick(card, FRONT_KEYS)
      back  = pick(card, BACK_KEYS)
      return if front.blank? || back.blank?

      { front: front, back: back }
    end

    def pick(card, keys)
      key = keys.find { |k| card[k].present? }
      card[key].to_s.strip if key
    end

    def fallback_name
      base = File.basename(@filename.to_s, ".*").tr("_-", "  ").strip
      base.presence || "Imported deck"
    end
  end
end
