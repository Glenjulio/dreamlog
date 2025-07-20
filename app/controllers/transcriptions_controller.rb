class TranscriptionsController < ApplicationController
  before_action :set_dream

  def show
    @transcription = @dream.transcription
    # Si aucune transcription n'est trouvée, tu peux gérer l'erreur ici
    # redirect_to edit_dream_path(@dream), notice: "No transcription found"
  end

  def edit
    @transcription = @dream.transcription || @dream.build_transcription
  end

  def update
    @transcription = @dream.transcription
    if @transcription.update(transcription_params)
      redirect_to dream_transcription_path(@dream), notice: "Transcription updated"
    else
      render :edit
    end
  end

  private

  def set_dream
    @dream = Dream.find(params[:dream_id])
  end

  def transcription_params
    params.require(:transcription).permit(:content)
  end
end
