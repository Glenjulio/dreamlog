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
      redirect_to @personality, notice: "Personnality created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @personality.update(personality_params)
      redirect_to @personality, notice: "Personality updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def my_personality
    if current_user.personality.present?
      redirect_to current_user.personality
    else
      redirect_to new_personality_path, notice: "Please create your personality first."
    end
  end

  private

  def set_personality
    @personality = Personality.find(params[:id])
  end

  def check_existing_personality
    return unless current_user.personality.present?

    redirect_to current_user.personality, notice: "You already have a personality set up."
  end

  def personality_params
    params.require(:personality).permit(
      :age, :job, :gender, :description, :relationship, :mood
    )
  end
end
