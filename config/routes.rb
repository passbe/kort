Rails.application.routes.draw do

  resources :probes do
    new do
      get "fields/:type", action: :fields, as: :fields
    end
    member do
      get :confirm
      post :execute
    end
  end
  resources :intervals do
    member do
      get :signal
      get "signal/start", to: "intervals#start", as: :start
      post "signal/log", to: "intervals#log", as: :log
      get :confirm
    end
  end
  resources :executions, only: [:index, :show] do
    member do
      get "download/log", to: "executions#download_log"
    end
  end
  resources :schedules, only: [:index, :show, :create] do
    collection do
      post :validate
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
  root "executions#index"
end
