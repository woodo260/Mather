class Card < ApplicationRecord
  belongs_to :deck
  has_many :card_reviews, dependent: :destroy

  validates :front, :back, presence: true
end
