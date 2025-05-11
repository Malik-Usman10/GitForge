Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  authenticated :user do
    root to: 'dashboard#index', as: :dashboard
    get 'dashboard/repositories', to: 'dashboard#repositories', as: :repositories
    get 'dashboard/starred', to: 'dashboard#starred', as: :starred
    get 'dashboard/explore', to: 'dashboard#explore', as: :explore
    get 'dashboard/settings', to: 'dashboard#settings', as: :settings
    get 'dashboard/repository', to: 'dashboard#repository', as: :repository
  end

  unauthenticated do
    root to: "home#index", as: :unauthenticated_root
  end

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root 'home#index'
  # Route for devise
  # config/routes.rb

end
