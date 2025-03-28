Rails.application.routes.draw do

  # Defines the root path route ("/")
  root "home#index"
  get "/session" => "application#sessionn"


  # authentication
  get "/auth" => "home#index"
  post "/auth/login" => "authentication#login"
  post "/auth/new" => "authentication#register"

  # user
  get "/user" => "home#index"
  patch "user/username" => "authentication#change_username"
  patch "user/password" => "authentication#change_password"
  delete "user" => "authentication#destroy"

  # atlas
  get "/atlas/:atlas_id" => "home#index"
  get "atlas/:atlas_id/info" => "atlases#show"
  get "/atlases" => "atlases#show_all"
  post "/atlas" => "atlases#create"
  delete "/atlas" => "atlases#delete"

  # sprites
  # get "images" => "images#index"
  get "/atlas/:atlas_id/sprites" => "sprite#show_all"
  post "/sprite" => "sprite#create"
  delete "/sprite" => "sprite#delete"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # resources :images, only: :create


end
