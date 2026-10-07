Rails.application.routes.draw do
     root "tasks#index"

     get "dashboard", to: "dashboard#index"

     get "login", to: "sessions#new"
     post "login", to: "sessions#create"
     delete "logout", to: "sessions#destroy"
     get "auth/:provider/callback", to: "sessions#omniauth", as: :omniauth_callback
     get "auth/failure", to: "sessions#failure"

     resources :users, only: %i[index new create edit update] do
          member do
               patch :revoke
               patch :restore
          end
     end

     get "organization", to: "organization#show"
     concern :archivable do
          member do
               patch :archive
               patch :restore
          end
     end
     resources :teams, :subteams, :projects, only: %i[show new create edit update], concerns: :archivable

     resources :tasks do
          resources :time_entries, only: %i[create edit update destroy], shallow: true
     end

     get "up" => "rails/health#show", as: :rails_health_check
end
