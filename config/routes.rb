Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "practice#show"

  resource  :settings, only: [ :show, :update ]
  get       "/practice",       to: "practice#show",  as: :practice
  post      "/practice/check", to: "practice#check", as: :check_practice
  get       "/practice/next",  to: "practice#next",  as: :next_practice
  resources :stats, only: [ :index ]

  # Deck import: upload an .apkg/JSON file, or pull a shared deck from AnkiWeb.
  resources :imports, only: [ :new ] do
    collection do
      post :file
      post :ankiweb
    end
  end

  resources :decks, only: [ :index, :show, :new, :create, :edit, :update, :destroy ] do
    resources :cards, only: [ :new, :create, :edit, :update, :destroy ]
    member do
      get  :review, to: "reviews#show"
      post "review/grade", to: "reviews#grade", as: :grade
    end
  end
  get "/review", to: "reviews#all", as: :review_all
end
