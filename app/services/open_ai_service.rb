# app/services/open_ai_service.rb
class OpenAiService
  include ActiveModel::Model

  attr_accessor :transcription, :personality

  def initialize(transcription:, personality: nil)
    @transcription = transcription
    @personality = personality

    validate_inputs!
    setup_client
  end

  def call
    Rails.logger.info "🧠 Generating AI analysis for transcription #{@transcription.id}"

    response = @client.chat(
      parameters: {
        model: "gpt-4",
        temperature: 0.7,
        max_tokens: 1500,
        messages: build_messages
      }
    )

    content = response.dig("choices", 0, "message", "content")

    Rails.logger.info "✅ AI analysis generated successfully"
    content

  rescue OpenAI::Error => e
    Rails.logger.error "❌ OpenAI API Error: #{e.message}"
    handle_openai_error(e)
  rescue StandardError => e
    Rails.logger.error "❌ Unexpected error in OpenAI service: #{e.message}"
    "Une erreur inattendue s'est produite lors de l'analyse. Veuillez réessayer."
  end

  private

  def validate_inputs!
    raise ArgumentError, "Transcription is required" if @transcription.nil?
    raise ArgumentError, "Transcription content is empty" if @transcription.content.blank?
    raise ArgumentError, "Transcription content is too short" if @transcription.content.length < 10
  end

  def setup_client
    api_key = ENV['OPENAI_API_KEY']
    raise ArgumentError, "OPENAI_API_KEY not configured" if api_key.blank?

    @client = OpenAI::Client.new(access_token: api_key)
  end

  def build_messages
    [
      { role: "system", content: system_prompt },
      { role: "user", content: user_message }
    ]
  end

  def system_prompt
    <<~PROMPT.strip
      Tu es un expert en interprétation des rêves, spécialisé dans l'analyse psychologique et symbolique.

      Ton rôle :
      - Analyser les rêves avec empathie et profondeur
      - Identifier les symboles, émotions et thèmes principaux
      - Proposer des interprétations basées sur la psychologie des rêves
      - Adapter ton analyse selon le profil du rêveur si fourni

      Format de réponse :
      - Structure claire avec sections (Symboles, Émotions, Interprétation, Conseils)
      - Ton bienveillant et professionnel
      - Éviter les affirmations absolues, utiliser "peut suggérer", "pourrait indiquer"
      - Maximum 1200 mots
    PROMPT
  end

  def user_message
    message = <<~MSG.strip
      Voici le rêve à analyser :

      "#{@transcription.content}"
    MSG

    if @personality.present?
      message += "\n\n" + personality_context
    end

    message
  end

  def personality_context
    context = "Profil du rêveur :\n"
    context += "- Âge : #{@personality.age} ans\n" if @personality.age.present?
    context += "- Genre : #{@personality.gender}\n" if @personality.gender.present?
    context += "- Profession : #{@personality.job}\n" if @personality.job.present?
    context += "- Humeur actuelle : #{@personality.mood}\n" if @personality.mood.present?
    context += "- Situation relationnelle : #{@personality.relationship}\n" if @personality.relationship.present?
    context += "- Description personnelle : #{@personality.description}\n" if @personality.description.present?

    context += "\nAdapte ton analyse en tenant compte de ces informations personnelles."
    context
  end

  def handle_openai_error(error)
    case error
    when OpenAI::RequestError
      if error.message.include?("rate_limit")
        "Le service d'analyse est temporairement surchargé. Veuillez réessayer dans quelques minutes."
      elsif error.message.include?("insufficient_quota")
        "Le quota d'analyse a été atteint. Veuillez contacter l'administrateur."
      else
        "Erreur lors de la connexion au service d'analyse. Vérifiez votre connexion internet."
      end
    when OpenAI::TimeoutError
      "Le service d'analyse met trop de temps à répondre. Veuillez réessayer."
    else
      "Service d'analyse temporairement indisponible. Veuillez réessayer plus tard."
    end
  end
end
