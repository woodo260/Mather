class CardReview < ApplicationRecord
  belongs_to :card

  RATINGS = %w[again hard good easy].freeze

  validates :session_token, presence: true
  validates :ease_factor, numericality: { greater_than_or_equal_to: 1.3 }
  validates :repetitions, :interval_days,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # The SM-2 state for a (session, card) pair, initialized with defaults when the
  # card has never been reviewed by this session.
  def self.for(token, card)
    find_or_initialize_by(session_token: token, card_id: card.id)
  end

  # Cards from `deck_ids` that this session should study now: those whose review is
  # due (due_on <= today) plus never-seen cards. Due cards come first (soonest due),
  # then new cards in deck order. Returns Card records.
  def self.queue_for(token, deck_ids)
    join = sanitize_sql_array([
      "LEFT JOIN card_reviews ON card_reviews.card_id = cards.id AND card_reviews.session_token = ?",
      token
    ])

    Card.where(deck_id: deck_ids)
        .joins(join)
        .where("card_reviews.id IS NULL OR card_reviews.due_on <= ?", Date.current)
        .order(Arel.sql("(card_reviews.due_on IS NULL) ASC, card_reviews.due_on ASC, cards.position ASC, cards.id ASC"))
  end

  # Counts of due (previously seen, due today or earlier) and new (never seen) cards
  # for a deck, so the index can show "3 due · 5 new" without loading every card.
  def self.counts_for(token, deck_ids)
    reviewed = where(session_token: token, card_id: Card.where(deck_id: deck_ids).select(:id))
    seen_ids = reviewed.pluck(:card_id)
    total    = Card.where(deck_id: deck_ids).count
    due      = reviewed.where("due_on <= ?", Date.current).count
    { due: due, new: total - seen_ids.size, total: total }
  end
end
