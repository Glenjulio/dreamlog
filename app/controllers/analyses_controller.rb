class AnalysesController < ApplicationController
  before_action :set_dream

  # Crée une analyse basée sur la transcription du rêve
  def create
    @transcription = @dream.transcription

    # Si aucune transcription n'est trouvée, redirige l'utilisateur vers l'édition de la transcription
    if @transcription.nil?
      redirect_to edit_dream_transcription_path(@dream), notice: "Please add a transcription first."
      return
    end

    # Détecte la langue de la transcription
    language = detect_language(@transcription.content)

    # Prépare le prompt pour l'API ChatGPT
    prompt = build_prompt(@transcription.content, language)

    # Appel à l'API OpenAI pour l'analyse du rêve
    client = OpenAI::Client.new
    response = client.chat(
      parameters: {
        model: "gpt-4",  # Utilisation du modèle GPT-4
        messages: [
          { role: "system", content: "You are a psychologist analyzing dreams." },
          { role: "user", content: prompt }
        ],
        temperature: 0.7
      }
    )

    # Récupère le résultat de l'analyse de l'API
    result = response.dig("choices", 0, "message", "content")

    # Crée une analyse dans la base de données
    @analysis = @transcription.analyses.create(content: result)

    # Redirige l'utilisateur vers la page de l'analyse créée
    redirect_to dream_analysis_path(@dream, @analysis), notice: "Dream analysis created successfully."
  end

  # Affiche l'analyse
  def show
    @transcription = @dream.transcription
    @analysis = @transcription.analyses.first  # Récupère la première analyse associée à la transcription
  end

  # Supprime l'analyse
  def destroy
    @analysis = Analysis.find(params[:id])
    @analysis.destroy
    redirect_back fallback_location: root_path, notice: "Analysis deleted."
  end

  private

  # Méthode pour récupérer le rêve avec l'ID donné
  def set_dream
    @dream = Dream.find(params[:dream_id])
  end

  # Méthode pour détecter la langue en fonction des caractères spéciaux
  def detect_language(text)
    french_characters = /[àâçéèêëîïôûùüÿ]/i
    if french_characters.match?(text)
      return 'fr'
    else
      return 'en'
    end
  end

  # Méthode pour construire le prompt en fonction de la langue détectée
  def build_prompt(content, language)
    if language == 'fr'
      <<~PROMPT
        Analysez le texte suivant d'un rêve en français. Identifiez et décrivez :
        - Les émotions ressenties par le rêveur
        - La signification symbolique des éléments majeurs
        Transcription :
        #{content}
      PROMPT
    else
      <<~PROMPT
        Analyze the following dream transcript in English. Identify and describe:
        - The emotions experienced by the dreamer
        - The symbolic meaning of major elements
        Transcript:
        #{content}
      PROMPT
    end
  end
end
