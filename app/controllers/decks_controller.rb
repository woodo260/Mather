class DecksController < ApplicationController
  # Flashcards don't need practice settings; don't bounce visitors to Settings.
  skip_before_action :ensure_settings

  before_action :set_deck,        only: %i[show edit update destroy]
  before_action :require_editable, only: %i[edit update destroy]

  def index
    @builtin_decks = Deck.builtin.order(:name)
    @my_decks      = Deck.owned_by(session_token).order(:name)
    @counts        = deck_counts(@builtin_decks + @my_decks)
    @total_due     = @counts.values.sum { |c| c[:due] }
  end

  def show
    @counts = CardReview.counts_for(session_token, [ @deck.id ])
  end

  def new
    @deck = Deck.new
  end

  def create
    @deck = Deck.new(deck_params.merge(session_token: session_token, builtin: false))
    if @deck.save
      redirect_to @deck, notice: "Deck created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @deck.update(deck_params)
      redirect_to @deck, notice: "Deck updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @deck.destroy
    redirect_to decks_path, notice: "Deck deleted."
  end

  private

  def set_deck
    @deck = Deck.visible_to(session_token).find(params[:id])
  end

  def require_editable
    redirect_to decks_path, alert: "That deck can't be edited." unless @deck.editable?
  end

  def deck_params
    params.require(:deck).permit(:name, :description)
  end

  def deck_counts(decks)
    decks.index_with { |deck| CardReview.counts_for(session_token, [ deck.id ]) }
  end
end
