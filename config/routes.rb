Rails.application.routes.draw do
     root "dashboard#index"

     get "login", to: "sessions#new"
     post "login", to: "sessions#create"
     delete "logout", to: "sessions#destroy"

     resources :users, only: %i[index edit update]

     resources :tasks do
          resources :time_entries, only: %i[create edit update destroy], shallow: true
     end

     get "up" => "rails/health#show", as: :rails_health_check
end
