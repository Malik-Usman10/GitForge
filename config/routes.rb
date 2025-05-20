Rails.application.routes.draw do
  devise_for :users

  get "up" => "rails/health#show", as: :rails_health_check

  authenticated :user do
    root to: 'dashboard#index', as: :dashboard

    namespace :dashboard do
      get '/', to: 'dashboard#index'
      resources :issues
      resources :pull_request
      get 'starred'
      get 'explore'
      get 'settings'
    end

    # Routes for repositories under username
    get '/:username/repositories', to: 'repositories#index', as: 'user_repositories'
    resources :repositories, except: [:index, :show] do
      member do
        post :sync
      end
    end
  end

  unauthenticated do
    root to: "home#index", as: :unauthenticated_root
  end

  # User profile route - accessible to both authenticated and unauthenticated users
  get '/:username', to: 'users#show', as: 'user'

  # For public/private repo view
  get '/:username/:repository_name', to: 'repositories#show', as: 'user_repository'
end
