Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  root "events#new"
  resources :events, only: [ :new, :create, :show, :edit, :update, :destroy ], path: "e" do
    resources :participants, only: :create
    post :slots, to: "availabilities#update", on: :member
    get :manage, on: :member
  end
end
