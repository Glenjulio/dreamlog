class DreamsController < ApplicationController
  before_action :authenticate_user!

  def mydreams
    puts current_user.inspect  # Vérifie que current_user est bien un User
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

  protect_from_forgery except: :upload_audio # for JS uploads

  def upload_audio
    dream = current_user.dreams.create! # or find_or_initialize_by(...) if editing existing
    dream.audio.attach(params[:audio])

    render json: { success: true, id: dream.id }, status: :ok
  end

  private

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
