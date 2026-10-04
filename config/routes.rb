Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "events#new"
  resources :events, only: [ :new, :create, :show ], path: "e" do
    resources :participants, only: :create
    post :slots, to: "availabilities#update", on: :member
  end
end
