Rails.application.routes.draw do
  devise_for :users

  root to: "pages#home" # page d'accueil publique

  # Personalities (Personnalités)
  resources :personalities, exept: [:destroy] do
    collection do
      get :my_personality # route pour la personnalité de l'utilisateur
    end
  end

  # Rêves (Dreams)
  resources :dreams do
    member do
      patch :private
      patch :public
    end

    # Transcription liée à un rêve
    resource :transcription, only: [:create, :show, :edit, :update] do
      # Analyses liées à une transcription
      resources :analyses, only: [:create, :show, :index]
    end
  end

  # Route nommée pour les rêves de l'utilisateur
  get '/mydreams', to: 'dreams#mydreams', as: :mydreams

  # Health check pour uptime monitoring
  get "up" => "rails/health#show", as: :rails_health_check
end
