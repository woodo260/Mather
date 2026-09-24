class ReviewsController < ApplicationController
  skip_before_action :ensure_settings

  # GET /decks/:id/review — review a single deck.
  def show
    @deck     = Deck.visible_to(session_token).find(params[:id])
    @scope    = "deck"
    @deck_ids = [ @deck.id ]
    prepare_next
    render :show
  end

  # GET /review — review everything due across all visible decks.
  def all
    @deck     = nil
    @scope    = "all"
    @deck_ids = Deck.visible_to(session_token).pluck(:id)
    prepare_next
    render :show
  end

  # POST /decks/:id/review/grade — record a self-graded rating and serve the next card.
  def grade
    @scope = params[:scope] == "all" ? "all" : "deck"
    deck   = Deck.visible_to(session_token).find(params[:id])
    card   = Card.find(params[:card_id])

    return head(:forbidden) unless Deck.visible_to(session_token).exists?(id: card.deck_id)
    return head(:unprocessable_entity) unless CardReview::RATINGS.include?(params[:rating].to_s)

    review = CardReview.for(session_token, card)
    Flashcards::Scheduler.apply(review, params[:rating])
    review.save!

    @deck     = (@scope == "deck" ? deck : nil)
    @deck_ids = @scope == "all" ? Deck.visible_to(session_token).pluck(:id) : [ deck.id ]
    prepare_next(exclude_id: card.id)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update("review-frame", partial: "reviews/frame", locals: frame_locals)
      end
      format.html { redirect_to(@scope == "all" ? review_all_path : review_deck_path(deck)) }
    end
  end

  private

  # Load the next card in the queue (optionally skipping the one just graded so a
  # lapsed card doesn't reappear back-to-back) and how many remain.
  def prepare_next(exclude_id: nil)
    relation = CardReview.queue_for(session_token, @deck_ids)
    @remaining = relation.count
    scoped = exclude_id ? relation.where.not(id: exclude_id) : relation
    @card = scoped.first || (exclude_id ? relation.first : nil)
  end

  def frame_locals
    { card: @card, deck: @deck, scope: @scope, remaining: @remaining }
  end
end
