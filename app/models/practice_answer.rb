class PracticeAnswer < ApplicationRecord
  validates :session_token, :question_type, presence: true
  validates :correct, inclusion: { in: [ true, false ] }
  validates :difficulty, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :for_session, ->(token) { where(session_token: token) }
  scope :recent, -> { order(created_at: :desc) }

  # Returns the number of consecutive calendar days (up to today) that have
  # at least one practice answer for this session token.
  def self.streak_for(token)
    dates = for_session(token)
              .order(created_at: :desc)
              .pluck(:created_at)
              .map { |t| t.to_date }
              .uniq

    return 0 if dates.empty?

    today = Date.today
    # Streak is broken if there's no activity today or yesterday
    return 0 unless dates.include?(today) || dates.include?(today - 1)

    streak = 0
    check  = dates.include?(today) ? today : today - 1

    loop do
      break unless dates.include?(check)
      streak += 1
      check  -= 1
    end

    streak
  end

  def self.accuracy_by_type(token)
    for_session(token)
      .group(:question_type)
      .select("question_type, COUNT(*) as total, SUM(CASE WHEN correct THEN 1 ELSE 0 END) as correct_count")
      .map do |row|
        {
          key:      row.question_type,
          label:    Questions::Registry[row.question_type]&.label || row.question_type.humanize,
          total:    row.total,
          correct:  row.correct_count,
          accuracy: row.total.positive? ? (row.correct_count * 100.0 / row.total).round(1) : 0,
        }
      end
      .sort_by { |r| -r[:total] }
  end
end
