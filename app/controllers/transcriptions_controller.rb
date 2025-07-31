class TranscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_dream
  before_action :set_transcription, only: [:show, :edit, :update]

  def show
    unless @transcription
      redirect_to edit_dream_path(@dream),
                  notice: "No transcription found. Please add one or transcribe the audio."
      return
    end

    @analysis = @transcription.analysis
  end

  def edit
    unless @transcription
      # Si la transcription n'existe pas, on la crée avec des valeurs par défaut
      @transcription = @dream.build_transcription(
        content: "",
        mood: "neutral",
        tag: "manual_entry"
      )
    end
  end

  def update
    # Vérification si la transcription existe déjà
    if @transcription
      if @transcription.update(transcription_params)
        # Si la mise à jour réussit, rediriger vers la page de génération de l'analyse
        redirect_to generate_dream_analysis_path(@dream)
      else
        flash.now[:alert] = "Please correct the errors below."
        render :edit, status: :unprocessable_entity
      end
    else
      # Si la transcription n'existe pas, la créer avant de tenter de la mettre à jour
      @transcription = @dream.create_transcription(transcription_params)
      if @transcription.save
        # Si la création réussit, rediriger vers la génération de l'analyse
        redirect_to generate_dream_analysis_path(@dream)
      else
        flash.now[:alert] = "Error creating transcription."
        render :edit, status: :unprocessable_entity
      end
    end
  end

  private

  def set_dream
    @dream = current_user.dreams.find(params[:dream_id])
  end

  def set_transcription
    # Vérifier si la transcription existe
    @transcription = @dream.transcription || nil
  end

  def transcription_params
    params.require(:transcription).permit(:content, :tag, :mood, :dream_type, :rating)
  end
end
