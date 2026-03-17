class StatsController < ApplicationController
  def index
    @accuracy_by_type = PracticeAnswer.accuracy_by_type(session_token)
    @total_answered   = PracticeAnswer.for_session(session_token).count
    @total_correct    = PracticeAnswer.for_session(session_token).where(correct: true).count
    @overall_accuracy = @total_answered.positive? ? (@total_correct * 100.0 / @total_answered).round(1) : 0
    @streak           = PracticeAnswer.streak_for(session_token)
    @recent_answers   = PracticeAnswer.for_session(session_token).recent.limit(20)
  end
end
