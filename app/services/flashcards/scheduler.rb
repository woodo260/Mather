module Flashcards
  # Classic SM-2 spaced-repetition scheduler. Given a CardReview and a self-graded
  # rating, returns the same (unsaved) review with its ease factor, repetition count,
  # interval and next due date advanced. Persisting is the caller's job.
  #
  # The four Anki-style ratings map onto SM-2's 0..5 quality scale:
  #   again -> 1   hard -> 3   good -> 4   easy -> 5
  # A rating below "good" (q < 3) is a lapse: repetitions reset and the card is due
  # again today so it stays in the current session's queue.
  class Scheduler
    QUALITY = { "again" => 1, "hard" => 3, "good" => 4, "easy" => 5 }.freeze
    MIN_EASE = 1.3

    def self.apply(review, rating)
      q = QUALITY.fetch(rating.to_s)

      if q < 3
        review.repetitions   = 0
        review.interval_days = 0
      else
        review.interval_days =
          case review.repetitions
          when 0 then 1
          when 1 then 6
          else        (review.interval_days * review.ease_factor).round
          end
        review.repetitions += 1
      end

      review.ease_factor = [
        MIN_EASE,
        review.ease_factor + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
      ].max.round(2)

      review.due_on           = Date.current + review.interval_days
      review.last_reviewed_at = Time.current
      review
    end
  end
end
