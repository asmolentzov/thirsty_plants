require 'sidekiq/web'
Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  root 'welcome#index'
  get '/auth/google_oauth2', as: 'signin'
  get '/auth/google_oauth2/callback', to: 'sessions#create'
  get '/signout', to: 'sessions#destroy'
  get '/invite', to: 'invite#show'
  post '/invite', to: 'invite#create'

  get '/dashboard', to: "users#show"

  resources :gardens, shallow: true do
    resources :plants, except: [:index]
  end
  resources :waterings, only: [:update]
  resources :schedules, only: [:index]

  namespace :admin do
    get '/dashboard', to: "users#index"
  end

  resources :users, only: [:update]
end
