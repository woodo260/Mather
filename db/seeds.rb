# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Built-in flashcard decks. Each YAML file in db/flashcard_decks defines a deck
# (slug/name/description) and its cards. Seeding is idempotent: decks are keyed by
# slug, and each deck's cards are replaced so edits to the YAML propagate on re-seed.
Dir[Rails.root.join("db/flashcard_decks/*.yml")].sort.each do |path|
  data = YAML.safe_load_file(path)

  deck = Deck.find_or_initialize_by(slug: data.fetch("slug"))
  deck.update!(
    name:        data.fetch("name"),
    description: data["description"],
    builtin:    true
  )

  deck.cards.destroy_all
  data.fetch("cards").each_with_index do |card, i|
    deck.cards.create!(front: card.fetch("front"), back: card.fetch("back"), position: i)
  end

  puts "Seeded deck '#{deck.name}' (#{deck.cards.count} cards)"
end
