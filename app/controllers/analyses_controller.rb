class AnalysesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_dream

  def show
    @analysis = Analysis.find(params[:id])
    @transcription = @analysis.transcription
    @dream = @transcription.dream

    unless @dream == Dream.find(params[:dream_id])
      redirect_to mydreams_path, alert: "Analysis does not belong to this dream"
      return
    end
  end

  def generate
    @transcription = @dream.transcription

    # Vérifications préalables
    unless @transcription.present?
      redirect_to edit_dream_path(@dream),
                  alert: "Please add a transcription before generating an analysis."
      return
    end

    # Vérifier si une analyse existe déjà
    if @transcription.analysis.present?
      redirect_to dream_analysis_path(@dream, @transcription.analysis),
                  notice: "Analysis already exists for this transcription."
      return
    end

    # Générer l'analyse avec feedback utilisateur
    begin
      Rails.logger.info "tarting AI analysis generation for dream #{@dream.id}"

      analysis_content = generate_analysis_content

      # Créer l'analyse en base
      @analysis = @transcription.create_analysis!(content: analysis_content)

      Rails.logger.info "Analysis created successfully with ID #{@analysis.id}"

      redirect_to dream_analysis_path(@dream, @analysis),
                  notice: "Analysis generated successfully!"

    rescue StandardError => e
      Rails.logger.error "Error in analysis generation: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")

      redirect_to dream_transcription_path(@dream),
                  alert: "Unable to generate analysis. Please try again later."
    end
  end

  private

  def set_dream
    @dream = current_user.dreams.find(params[:dream_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to mydreams_path, alert: "Dream not found"
  end

  def generate_analysis_content
    # Utiliser le service OpenAI avec la personnalité de l'utilisateur
    OpenAiService.new(
      transcription: @transcription,
      personality: current_user.personality
    ).call
  end
end
