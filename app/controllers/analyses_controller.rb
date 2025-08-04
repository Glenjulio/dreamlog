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

    unless @transcription.present?
      redirect_to edit_dream_path(@dream),
                  alert: "Please add a transcription before generating an analysis."
      return
    end

    if @transcription.analysis.present?
      redirect_to dream_analysis_path(@dream, @transcription.analysis),
                  notice: "Analysis already exists for this transcription."
      return
    end

    begin
      Rails.logger.info "🚀 Starting AI analysis generation for dream #{@dream.id}"

      analysis_data = generate_analysis_data

      if analysis_data.key?("error")
        raise StandardError, analysis_data["error"]
      end

      @analysis = @transcription.create_analysis!(data: analysis_data)

      Rails.logger.info "✅ Analysis created successfully with ID #{@analysis.id}"

      redirect_to dream_analysis_path(@dream, @analysis),
                  notice: "Analysis generated successfully!"

    rescue StandardError => e
      Rails.logger.error "❌ Error in analysis generation: #{e.message}"
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

  def generate_analysis_data
    OpenAiService.new(
      transcription: @transcription,
      personality: current_user.personality
    ).call
  end
end
