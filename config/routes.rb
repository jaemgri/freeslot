Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "events#new"
  resources :events, only: [ :new, :create, :show ], path: "e" do
    resources :participants, only: :create
    post :toggle, to: "availabilities#toggle", on: :member
  end
end
