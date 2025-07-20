# app/controllers/analyses_controller.rb
class AnalysesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_dream

  def show
    @analysis = @dream.transcription&.analyses&.find(params[:id])
    redirect_to mydreams_path, alert: "Analysis not found" unless @analysis
  end

  def generate
    @transcription = @dream.transcription

    # Si aucune transcription n'existe, on redirige pour l'ajouter
    if @transcription.blank?
      redirect_to edit_dream_path(@dream),
                  alert: "Please add a transcription before generating an analysis."
      return
    end

    # Vérifier si une analyse existe déjà
    existing_analysis = @transcription.analyses.first
    if existing_analysis.present?
      redirect_to dream_analysis_path(@dream, existing_analysis),
                  notice: "Analysis already exists for this dream."
      return
    end

    begin
      # Générer l'analyse en fonction du contenu de la transcription
      analysis_content = generate_analysis_content(@transcription.content)
      @analysis = @transcription.analyses.create!(content: analysis_content)

      # Redirige vers l'analyse nouvellement créée
      redirect_to dream_analysis_path(@dream, @analysis),
                  notice: "Analysis generated successfully!"
    rescue => e
      redirect_to dream_transcription_path(@dream),
                  alert: "Error generating analysis: #{e.message}"
    end
  end

  private

  def set_dream
    @dream = current_user.dreams.find(params[:dream_id])
  end

  def generate_analysis_content(transcription_content)
    "Analyse automatique du rêve : #{transcription_content.truncate(100)}"
  end
end
