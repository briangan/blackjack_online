Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  resources :tables, only:[:create, :destroy, :show, :index] do
    member do
      match 'add_user', to: 'tables#add_user', via:[:post]
      match 'delete_user/:table_user_id', to: 'tables#delete_user', via:[:delete], as:'delete_user'
      match 'create_game', to: 'tables#create_game', via:[:post]
    end
  end

  resources :games, only:[:show, :create] do
    member do
      match 'new_hand', to: 'games#new_hand', via:[:get]
      match 'create_hand', to: 'games#create_hand', via:[:post]
    end
  end
  get "cards" => "cards#index"

  # Defines the root path route ("/")
  root "tables#index"
end
