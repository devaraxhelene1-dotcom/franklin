Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :campaigns, only: [:index, :show, :edit, :update] do
    resources :steps, only: [:show, :edit, :update]
  end
  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "/dashboard", to: "pages#dashboard"

  resources :chats, only: [:show, :create] do
    resources :messages, only: [:create]
  end
  # Defines the root path route ("/")
  # root "posts#index"
end
