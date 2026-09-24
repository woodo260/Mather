class Deck < ApplicationRecord
  has_many :cards, -> { order(:position, :id) }, dependent: :destroy, inverse_of: :deck

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  scope :builtin,  -> { where(builtin: true) }
  scope :owned_by, ->(token) { where(builtin: false, session_token: token) }
  scope :visible_to, ->(token) { where("builtin = ? OR session_token = ?", true, token) }

  before_validation :ensure_slug, on: :create

  # Built-in decks are seeded and shared; only user decks can be edited or deleted.
  def editable?
    !builtin
  end

  private

  def ensure_slug
    return if slug.present?

    base = name.to_s.parameterize
    base = "deck" if base.blank?
    candidate = base
    i = 2
    while Deck.exists?(slug: candidate)
      candidate = "#{base}-#{i}"
      i += 1
    end
    self.slug = candidate
  end
end
