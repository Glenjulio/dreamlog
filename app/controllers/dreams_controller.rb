class DreamsController < ApplicationController
  before_action :authenticate_user!

  def mydreams
    @dreams = current_user.dreams
  end

  def index
    @dreams = Dream.where(private: false)
  end

  def new
    @dream = Dream.new
    @dream.build_transcription  # nécessaire pour afficher le champ dans le formulaire
  end

  def create
    @dream = current_user.dreams.build(dream_params)
    if @dream.save
      redirect_to mydreams_path, notice: "Rêve créé avec succès"
    else
      render :new
    end
  end

  def show
    @dream = Dream.find(params[:id])
  end

  def edit
    @dream = Dream.find(params[:id])
    @dream.build_transcription unless @dream.transcription
  end

  def update
    @dream = Dream.find(params[:id])
    if @dream.update(dream_params)
      redirect_to mydreams_path, notice: "Dream updated successfully"
    else
      render :edit
    end
  end

  private

  def dream_params
    params.require(:dream).permit(
      :title,
      :tags,
      :private,
      transcription_attributes: [:content]
    )
  end
end
