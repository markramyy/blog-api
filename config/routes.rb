Rails.application.routes.draw do
  require 'sidekiq/web'

  # Configure Sidekiq authentication
  SidekiqAuth::Web.use!(
    username: ENV.fetch('SIDEKIQ_USERNAME', 'admin'),
    password: ENV.fetch('SIDEKIQ_PASSWORD', 'password')
  )

  mount Sidekiq::Web => '/sidekiq'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    namespace :v1 do
      post 'auth/signup', to: 'auth#signup'
      post 'auth/login', to: 'auth#login'

      resources :tags, only: [:index, :create]
      resources :posts, only: [:index, :show, :create, :update, :destroy] do
        resources :comments, only: [:index, :create, :update, :destroy]
      end
    end
  end
end
