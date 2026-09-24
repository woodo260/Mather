module Flashcards
  # Raised when an import can't be completed for a reason worth showing the user
  # (bad file, unreadable Anki package, AnkiWeb refusing the download, etc.).
  class ImportError < StandardError; end
end
