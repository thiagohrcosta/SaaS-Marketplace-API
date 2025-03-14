Rails.application.routes.draw do
  # devise_for :users
  
  # get "up" => "rails/health#show", as: :rails_health_check

  devise_for :users, controllers: {
    registrations: 'api/v1/users/registrations'
  }
  namespace :api do
    namespace :v1 do
      resources :users, only: [:create]
      
      get "profile", to: "users#profile"

      resources :sessions, only: [:create, :destroy]

      post '/login', to: 'sessions#login_with_magic_link'

      resources :users, only: [:show, :create] 

      resources :companies, only: [:create, :update]

      post "/graphql", to: "graphql#execute" 

      resources :categories
      resources :products

      resources :orders
      resources :product_orders
    end
  end
end
