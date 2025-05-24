Rails.application.routes.draw do
  devise_for :users, controllers: {
    confirmations: 'confirmations'
  }

  get "up" => "rails/health#show", as: :rails_health_check

  # Letter opener web interface for development environment
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  authenticated :user do
    root to: 'dashboard#index', as: :dashboard

    namespace :dashboard do
      get '/', to: 'dashboard#index'
      get 'starred'
      get 'explore'
      get 'settings'
    end
    
    # Settings routes
    patch '/settings/profile', to: 'settings#update_profile', as: 'update_profile'
    patch '/settings/password', to: 'settings#update_password', as: 'update_password'

    # Routes for repositories under username
    get '/:username/repositories', to: 'repositories#index', as: 'user_repositories'
    resources :repositories, except: [:index, :show] do
      member do
        post :sync
      end
    end
    
    # Global issues, pull requests, and commits - these routes will still work but aren't linked
    resources :issues, except: [:index, :show] do
      member do
        patch :close
        patch :reopen
      end
    end
    
    resources :pull_requests, except: [:index, :show] do
      member do
        patch :merge
        patch :close
        patch :reopen
      end
    end
    
    resources :commits, only: [] # No global commit routes, all are repository-specific
    
    # User-specific routes for issues, pull requests, and commits
    get '/:username/issues', to: 'issues#index', as: 'user_issues'
    get '/:username/issues/new', to: 'issues#new', as: 'new_user_issue'
    get '/:username/pull-requests', to: 'pull_requests#index', as: 'user_pull_requests'
    get '/:username/pull-requests/new', to: 'pull_requests#new', as: 'new_user_pull_request'
    get '/:username/commits', to: 'commits#index', as: 'user_commits'
  end

  unauthenticated do
    root to: "home#index", as: :unauthenticated_root
  end

  # User profile route - accessible to both authenticated and unauthenticated users
  get '/:username', to: 'users#show', as: 'user'

  # Repository routes
  get '/:username/:repository_name', to: 'repositories#show', as: 'user_repository'
  
  # Repository-specific issues routes
  get '/:username/:repository_name/issues', to: 'issues#index', as: 'user_repository_issues'
  get '/:username/:repository_name/issues/new', to: 'issues#new', as: 'new_user_repository_issue'
  post '/:username/:repository_name/issues', to: 'issues#create'
  get '/:username/:repository_name/issues/:id', to: 'issues#show', as: 'user_repository_issue'
  get '/:username/:repository_name/issues/:id/edit', to: 'issues#edit', as: 'edit_user_repository_issue'
  patch '/:username/:repository_name/issues/:id', to: 'issues#update'
  put '/:username/:repository_name/issues/:id', to: 'issues#update'
  delete '/:username/:repository_name/issues/:id', to: 'issues#destroy'
  patch '/:username/:repository_name/issues/:id/close', to: 'issues#close', as: 'close_user_repository_issue'
  patch '/:username/:repository_name/issues/:id/reopen', to: 'issues#reopen', as: 'reopen_user_repository_issue'
  
  # Repository-specific pull requests routes
  get '/:username/:repository_name/pull_requests', to: 'pull_requests#index', as: 'user_repository_pull_requests'
  get '/:username/:repository_name/pull_requests/new', to: 'pull_requests#new', as: 'new_user_repository_pull_request'
  post '/:username/:repository_name/pull_requests', to: 'pull_requests#create'
  get '/:username/:repository_name/pull_requests/:id', to: 'pull_requests#show', as: 'user_repository_pull_request'
  get '/:username/:repository_name/pull_requests/:id/edit', to: 'pull_requests#edit', as: 'edit_user_repository_pull_request'
  patch '/:username/:repository_name/pull_requests/:id', to: 'pull_requests#update'
  put '/:username/:repository_name/pull_requests/:id', to: 'pull_requests#update'
  delete '/:username/:repository_name/pull_requests/:id', to: 'pull_requests#destroy'
  patch '/:username/:repository_name/pull_requests/:id/merge', to: 'pull_requests#merge', as: 'merge_user_repository_pull_request'
  patch '/:username/:repository_name/pull_requests/:id/close', to: 'pull_requests#close', as: 'close_user_repository_pull_request'
  patch '/:username/:repository_name/pull_requests/:id/reopen', to: 'pull_requests#reopen', as: 'reopen_user_repository_pull_request'
  
  # Repository-specific commits routes
  get '/:username/:repository_name/commits', to: 'commits#index', as: 'user_repository_commits'
  get '/:username/:repository_name/commits/:id', to: 'commits#show', as: 'user_repository_commit'
end
