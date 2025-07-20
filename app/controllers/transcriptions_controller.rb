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
    
    @analysis = @transcription.analyses.first  # Récupération de l'analyse associée
  end

  def edit
    unless @transcription
      @transcription = @dream.build_transcription(
        content: "",
        mood: "neutral",
        tag: "manual_entry"
      )
    end
  end

  def update
    if @transcription.update(transcription_params)
      redirect_to dream_transcription_path(@dream),
                  notice: "Transcription updated successfully!"
    else
      flash.now[:alert] = "Please correct the errors below."
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_dream
    @dream = current_user.dreams.find(params[:dream_id])
  end

  def set_transcription
    @transcription = @dream.transcription
  end

  def transcription_params
    params.require(:transcription).permit(:content, :mood, :tag, :rating)
  end
end
