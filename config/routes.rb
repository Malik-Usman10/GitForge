Rails.application.routes.draw do
  devise_for :users

  get "up" => "rails/health#show", as: :rails_health_check

  authenticated :user do
    root to: 'dashboard#index', as: :dashboard

    namespace :dashboard do
      get '/', to: 'dashboard#index'
      resources :repositories, only: [:index, :show, :new, :create]
      resources :issues
      resources :pull_request
      get 'starred'
      get 'explore'
      get 'settings'
    end
  end

  unauthenticated do
    root to: "home#index", as: :unauthenticated_root
  end
end
