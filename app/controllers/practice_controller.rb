class PracticeController < ApplicationController
  # At difficulty 0, whole-number rounding can produce differences up to 0.5
  ANSWER_TOLERANCE_BY_DIFFICULTY = [ 0.51, 0.06, 0.02, 0.02 ].freeze

  def show
    generate_question
  end

  def check
    stored = session[:current_question]
    unless stored
      redirect_to practice_path
      return
    end

    user_input   = params[:answer].to_s.strip.gsub(/[$,]/, "")
    user_answer  = user_input.to_f
    correct_answer = stored["answer"].to_f
    tolerance = answer_tolerance(stored["type"], correct_answer)
    @correct = (user_answer - correct_answer).abs <= tolerance

    @user_answer    = user_answer
    @correct_answer = correct_answer
    @prompt         = stored["prompt"]
    @explanation    = stored["explanation"]
    @steps          = stored["steps"] || []
    @question_type  = stored["type"]

    # Update in-session stats
    stats = practice_stats.dup
    if @correct
      stats["correct"] = stats["correct"].to_i + 1
    else
      stats["incorrect"] = stats["incorrect"].to_i + 1
    end
    session[:practice_stats] = stats

    # Persist to database
    record_practice_answer(
      question_type: @question_type,
      correct: @correct,
      prompt: @prompt
    )

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          "question-frame",
          partial: "practice/feedback",
          locals: {
            correct: @correct,
            user_answer: @user_answer,
            correct_answer: @correct_answer,
            prompt: @prompt,
            explanation: @explanation,
            steps: @steps
          }
        )
      end
      format.html { redirect_to practice_path }
    end
  end

  def next
    generate_question
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          "question-frame",
          partial: "practice/question",
          locals: { question: @question, difficulty: difficulty }
        )
      end
      format.html { redirect_to practice_path }
    end
  end

  private

  # Combine the absolute per-difficulty floor with a question-type relative
  # band, so approximation-based answers (unit conversions) aren't punished for
  # the ~1% drift the suggested mental shortcuts introduce, while exact
  # arithmetic keeps its tight tolerance.
  def answer_tolerance(type, correct_answer)
    absolute = ANSWER_TOLERANCE_BY_DIFFICULTY[difficulty] || 0.02
    relative = (Questions::Registry[type]&.relative_tolerance || 0.0) * correct_answer.abs
    [ absolute, relative ].max
  end

  def generate_question
    @question = Questions::Generator.call(types: active_types, difficulty: difficulty)
    session[:current_question] = {
      "type"        => @question.class.key,
      "answer"      => @question.answer,
      "prompt"      => @question.prompt,
      "explanation" => @question.explanation,
      "steps"       => @question.steps
    }
  end
end
