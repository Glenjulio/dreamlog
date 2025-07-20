Rails.application.routes.draw do
  devise_for :users

  root to: "pages#home"

  resources :personalities, except: [:destroy] do
    collection do
      get :my_personality # route pour la personnalité de l'utilisateur
    end
  end

  # Alias pour la page profil
  get "/profile", to: "personalities#my_personality", as: :profile

  resources :dreams do
    member do
      patch :private
      patch :public
    end

    resource :transcription, only: [:show, :edit, :update]

    # Analyses liées au rêve
    resources :analyses, only: [:show]  # Affichage de l'analyse uniquement
  end

  # Route pour générer l'enregistrement
  post 'dreams/upload_audio', to: 'dreams#upload_audio'
  direct_uploads = Rails.application.config.active_storage.routes
  draw(:active_storage) unless direct_uploads.nil?

  # Route pour générer l'analyse
  post 'dreams/:dream_id/analyses/generate', to: 'analyses#generate', as: 'generate_analysis'

  get '/mydreams', to: 'dreams#mydreams', as: :mydreams
  get "up" => "rails/health#show", as: :rails_health_check
end
