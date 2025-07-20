# config/routes.rb
Rails.application.routes.draw do
  devise_for :users

  root to: "pages#home"

  resources :personalities, except: [:destroy] do
    collection do
      get :my_personality
    end
  end

  # Alias pour la page profil
  get "/profile", to: "personalities#my_personality", as: :profile

  resources :dreams do
    resource :transcription, only: [:show, :edit, :update]

    resources :analyses, only: [:show] do
      collection do
        post :generate, to: 'analyses#generate'
      end
    end
  end

  # Route pour générer l'enregistrement
  post 'dreams/upload_audio', to: 'dreams#upload_audio'

  # Active Storage routes
  if Rails.application.config.respond_to?(:active_storage) && Rails.application.config.active_storage.routes
    draw(:active_storage)
  end

  get '/mydreams', to: 'dreams#mydreams', as: :mydreams
  get "up" => "rails/health#show", as: :rails_health_check
end
