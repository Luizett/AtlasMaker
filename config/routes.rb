Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"

  # authentication
  get "/session" => "application#authenticate_request"
  get "/auth" => "home#index"
  post "/auth/login" => "authentication#login"
  post "/auth/new" => "authentication#register"
  # user changing
  patch "user/username" => "authentication#change_username"
  patch "user/password" => "authentication#change_password"
  delete "user" => "authentication#destroy"


  get "/atlas" => "home#index"
  # post "/atlas" => "atlas#create"
  get "images" => "images#index"
  get "/user" => "home#index"
  post "/images" => "images#create"
  # resources :images, only: :create

  # TODO общий список планов
  # добавить функционал созания нового объекта атласа и отображение этих объектов в сетке
  # добавить открывание атласа в окне по нажатию
  # добавить приаттачивание нового спрайта к атласу по кнопке и отображение картинок в сетке
  # удаление атласов и удаление картинок из сетки
  # создать какой-то файл-сервис чтоб фетчить там всё внутри и просто возвращать функции в конечные файлы

end
