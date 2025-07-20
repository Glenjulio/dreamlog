class AnalysesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_dream

  def show
    @analysis = Analysis.find(params[:id])
    redirect_to mydreams_path, alert: "Analysis not found" unless @analysis
  end

  def create
    # Créer une analyse indépendamment d'une transcription
    @transcription = @dream.transcription
    @analysis = Analysis.create!(content: "Generated analysis for dream #{@dream.title}")

    # Redirection ou traitement après création
    redirect_to dream_analysis_path(@dream, @analysis), notice: "Analysis created successfully!"
  end

  def generate
    @transcription = @dream.transcription

    # Si aucune transcription n'existe, on redirige
    if @transcription.blank?
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

    # Créer une analyse pour cette transcription (has_one, pas has_many)
    @analysis = @transcription.create_analysis!(
      content: generate_analysis_content(@transcription.content)
    )

    redirect_to dream_analysis_path(@dream, @analysis), notice: "Analysis generated successfully!"
  rescue => e
    redirect_to dream_transcription_path(@dream), alert: "Error generating analysis: #{e.message}"
  end

  private

  def set_dream
    @dream = current_user.dreams.find(params[:dream_id])
  end

  def generate_analysis_content(transcription_text)
    # Génération d'analyse basique - peut être améliorée avec OpenAI plus tard
    "Analyse automatique du rêve :\n\n" +
    "Longueur de la transcription : #{transcription_text.length} caractères\n\n" +
    "Éléments détectés :\n" +
    "- Contenu émotionnel : #{detect_emotions(transcription_text)}\n" +
    "- Thèmes principaux : #{detect_themes(transcription_text)}\n\n" +
    "Cette analyse sera améliorée avec l'intégration d'IA."
  end

  def detect_emotions(text)
    emotions = []
    emotions << "fear" if text.downcase.match?(/fear|scared|terrified|nightmare/)
    emotions << "joy" if text.downcase.match?(/happy|joy|content|laugh/)
    emotions << "sadness" if text.downcase.match?(/sad|cry|melancholy/)
    emotions << "anger" if text.downcase.match?(/angry|mad|furious/)

    emotions.any? ? emotions.join(", ") : "neutral"
  end

  def detect_themes(text)
    themes = []
    themes << "family" if text.downcase.match?(/family|parent|mother|father|brother|sister/)
    themes << "work" if text.downcase.match?(/work|office|colleague|boss/)
    themes << "travel" if text.downcase.match?(/travel|car|plane|road/)
    themes << "home" if text.downcase.match?(/home|room|kitchen|living/)

    themes.any? ? themes.join(", ") : "daily life"
  end
end
