class DreamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_dream, only: [:show, :edit, :update, :destroy]

  def mydreams
    @dreams = current_user.dreams.order(created_at: :desc)
  end

  def index
    @dreams = Dream.where(private: false).order(created_at: :desc)
  end

  def new
    @dream = Dream.new
    @dream.build_transcription
  end

  def create
    @dream = current_user.dreams.build(dream_params)

    if @dream.save
      respond_to do |format|
        format.html { redirect_to mydreams_path, notice: "Rêve créé avec succès" }
        format.json { render json: { success: true, id: @dream.id }, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new }
        format.json { render json: { errors: @dream.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def show
  end

  def edit
    @dream.build_transcription unless @dream.transcription
  end

  def update
    if @dream.update(dream_params)
      redirect_to mydreams_path, notice: "Dream updated successfully"
    else
      render :edit
    end
  end

  def destroy
    @dream.destroy
    redirect_to mydreams_path, notice: "Dream deleted successfully"
  end

  protect_from_forgery except: :upload_audio

  def upload_audio
    dream = current_user.dreams.create!
    dream.audio.attach(params[:audio])

    render json: { success: true, id: dream.id }, status: :ok
  end

  private

  def set_dream
    @dream = current_user.dreams.find(params[:id])
  end

  def dream_params
    params.require(:dream).permit(
      :title,
      :tags,
      :private,
      :audio,
      transcription_attributes: [:content]
    )
  end
end
