class PersonalitiesController < ApplicationController
    before_action :authenticate_user!
  before_action :set_personality, only: [:show, :edit, :update]
  before_action :ensure_owner, only: [:edit, :update, :destroy]

  def index
    @personalities = Personality.includes(:user).all
  end

  def show
  end

  def new
    if current_user.personality.present?
      redirect_to personality_path(current_user.personality),
                  notice: "Vous avez déjà une personnalité."
      return
    end

    @personality = current_user.build_personality
  end

  def create
    if current_user.personality.present?
      redirect_to personality_path(current_user.personality),
                  notice: "Vous avez déjà une personnalité."
      return
    end

    @personality = current_user.build_personality(personality_params)

    if @personality.save
      redirect_to personality_path(@personality),
                  notice: "Personnalité créée avec succès."
    else
      render :new, status: :unprocessable_entity
    end
  end


  def edit
  end

  def update
    if @personality.update(personality_params)
      redirect_to personality_path(@personality),
                  notice: "Personnalité mise à jour avec succès."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def my_personality
    if current_user.personality.present?
      redirect_to personality_path(current_user.personality)
    else
      redirect_to new_personality_path,
                  notice: "Vous n'avez pas encore de personnalité."
    end
  end

  private

  def set_personality
    @personality = Personality.find(params[:id])
  end

  def ensure_owner
    unless @personality.user == current_user
      redirect_to personalities_path, alert: "Accès non autorisé."
    end
  end

  def personality_params
    params.require(:personality).permit(
      :age, :job, :gender, :description, :relationship, :mood
    )
  end
end
