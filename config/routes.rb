Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "practice#show"

  resource  :settings, only: [ :show, :update ]
  get       "/practice",       to: "practice#show",  as: :practice
  post      "/practice/check", to: "practice#check", as: :check_practice
  get       "/practice/next",  to: "practice#next",  as: :next_practice
  resources :stats, only: [ :index ]
end
