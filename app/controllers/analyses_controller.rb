class AnalysesController < ApplicationController
  before_action :authenticate_user!

  def show
    @analysis = Analysis.find(params[:id])
    redirect_to mydreams_path, alert: "Analysis not found" unless @analysis
  end

  def create
    # Créer une analyse indépendamment d'une transcription
    @dream = Dream.find(params[:dream_id])
    @transcription = @dream.transcription # Si nécessaire, on lierait l'analyse à une transcription
    @analysis = Analysis.create!(content: "Generated analysis for dream #{@dream.title}")

    # Redirection ou traitement après création
    redirect_to dream_analysis_path(@dream, @analysis), notice: "Analysis created successfully!"
  end

  def generate
    @dream = Dream.find(params[:dream_id])
    @transcription = @dream.transcription

    # Si aucune transcription n'existe, on redirige
    if @transcription.blank?
      redirect_to edit_dream_path(@dream),
                  alert: "Please add a transcription before generating an analysis."
      return
    end

    # Créer une analyse pour cette transcription
    @analysis = @transcription.analyses.create!(content: "Generated analysis for transcription")

    redirect_to dream_analysis_path(@dream, @analysis), notice: "Analysis generated!"
  rescue => e
    redirect_to dream_transcription_path(@dream), alert: "Error generating analysis: #{e.message}"
  end
end
