module Flashcards
  # Normalized result of parsing any import source. `cards` is an array of
  # `{ front:, back: }` hashes, already cleaned up and ready to persist.
  ParsedDeck = Struct.new(:name, :description, :cards, keyword_init: true)
end
