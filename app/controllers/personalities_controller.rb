class PersonalitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_personality, only: [:show, :edit, :update]
  before_action :check_existing_personality, only: [:new, :create]

  def index
    @personalities = Personality.includes(:user).all
  end

  def show
  end

  def new
    @personality = current_user.build_personality
  end

  def create
    @personality = current_user.build_personality(personality_params)

    if @personality.save
      redirect_to @personality, notice: "Personnalité créée avec succès."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @personality.update(personality_params)
      redirect_to @personality, notice: "Personnalité mise à jour avec succès."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def my_personality
    if current_user.personality.present?
      redirect_to current_user.personality
    else
      redirect_to new_personality_path, notice: "Vous n'avez pas encore de personnalité."
    end
  end

  private

  def set_personality
    @personality = Personality.find(params[:id])
  end

  def check_existing_personality
    return unless current_user.personality.present?

    redirect_to current_user.personality, notice: "Vous avez déjà une personnalité."
  end

  def personality_params
    params.require(:personality).permit(
      :age, :job, :gender, :description, :relationship, :mood
    )
  end
end
