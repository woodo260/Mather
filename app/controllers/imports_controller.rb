class ImportsController < ApplicationController
  # Importing doesn't need practice settings; don't bounce to Settings.
  skip_before_action :ensure_settings

  def new
  end

  def file
    deck = importer.import_file(params[:file])
    redirect_to deck, notice: imported_notice(deck)
  rescue Flashcards::ImportError => e
    import_failed(e)
  end

  def ankiweb
    deck = importer.import_from_ankiweb(params[:ankiweb])
    redirect_to deck, notice: imported_notice(deck)
  rescue Flashcards::ImportError => e
    import_failed(e)
  end

  private

  def importer
    @importer ||= Flashcards::DeckImporter.new(session_token: session_token)
  end

  def imported_notice(deck)
    "Imported “#{deck.name}” with #{helpers.pluralize(deck.cards.count, 'card')}."
  end

  def import_failed(error)
    flash.now[:alert] = error.message
    render :new, status: :unprocessable_entity
  end
end
