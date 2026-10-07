Rails.application.routes.draw do
     root "tasks#index"

     get "dashboard", to: "dashboard#index"

     get "login", to: "sessions#new"
     post "login", to: "sessions#create"
     delete "logout", to: "sessions#destroy"

     resources :users, only: %i[index edit update]

     get "organization", to: "organization#show"
     concern :archivable do
          member do
               patch :archive
               patch :restore
          end
     end
     resources :projects, :teams, :subteams, only: %i[new create edit update], concerns: :archivable

     resources :tasks do
          resources :time_entries, only: %i[create edit update destroy], shallow: true
     end

     get "up" => "rails/health#show", as: :rails_health_check
end
