class CardsController < ApplicationController
  skip_before_action :ensure_settings

  before_action :set_deck
  before_action :set_card, only: %i[edit update destroy]

  def new
    @card = @deck.cards.build
  end

  def create
    @card = @deck.cards.build(card_params.merge(position: next_position))
    if @card.save
      redirect_to @deck, notice: "Card added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @card.update(card_params)
      redirect_to @deck, notice: "Card updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @card.destroy
    redirect_to @deck, notice: "Card deleted."
  end

  private

  # Only decks the session owns (never built-in) can have cards managed.
  def set_deck
    @deck = Deck.owned_by(session_token).find(params[:deck_id])
  end

  def set_card
    @card = @deck.cards.find(params[:id])
  end

  def card_params
    params.require(:card).permit(:front, :back)
  end

  def next_position
    (@deck.cards.maximum(:position) || -1) + 1
  end
end
