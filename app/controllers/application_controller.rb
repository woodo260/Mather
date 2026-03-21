class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :ensure_session_token
  before_action :ensure_settings

  helper_method :current_settings, :session_token, :practice_stats, :difficulty

  private

  def ensure_session_token
    session[:session_token] ||= SecureRandom.uuid
  end

  def session_token
    session[:session_token]
  end

  def ensure_settings
    return if controller_name == "settings"
    unless session[:settings].present?
      redirect_to settings_path
    end
  end

  def current_settings
    @current_settings ||= session[:settings] || {}
  end

  def active_types
    current_settings["active_types"] || Questions::Registry.all_keys
  end

  def difficulty
    (current_settings["difficulty"] || 0).to_i
  end

  def practice_stats
    @practice_stats ||= session[:practice_stats] || { "correct" => 0, "incorrect" => 0 }
  end

  def record_practice_answer(question_type:, correct:, prompt:)
    PracticeAnswer.create!(
      session_token: session_token,
      question_type: question_type,
      difficulty:    difficulty,
      correct:       correct,
      prompt:        prompt
    )
  end
end
