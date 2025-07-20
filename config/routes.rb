Rails.application.routes.draw do
  devise_for :users

  root to: "pages#home"

  # Personalities (Personnalités)
  resources :personalities, except: [:destroy] do
    collection do
      get :my_personality # route pour la personnalité de l'utilisateur
    end
  end

  # Alias pour la page profil
  get "/profile", to: "personalities#my_personality", as: :profile

  # Rêves (Dreams)
  resources :dreams do
    member do
      patch :private
      patch :public
    end

    # Transcription liée à un rêve (resource unique pour chaque rêve)
    resource :transcription, only: [:show, :edit, :update] do
      # Analyses liées à une transcription
      resources :analyses, only: [:create, :show, :index]
    end
  end

  # Route nommée pour les rêves de l'utilisateur
  get '/mydreams', to: 'dreams#mydreams', as: :mydreams

  # Health check pour uptime monitoring
  get "up" => "rails/health#show", as: :rails_health_check
end
