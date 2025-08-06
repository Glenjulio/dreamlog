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

    detected_language = detect_language(@transcription.content)
    Rails.logger.info "🌍 Detected language: #{detected_language}"

    @language_code = detected_language || 'fr'

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

    # 🔁 Tenter de parser le JSON en hash Ruby
    begin
      JSON.parse(content)
    rescue JSON::ParserError => e
      Rails.logger.error "❌ Invalid JSON format from OpenAI: #{e.message}"
      { error: "Invalid JSON format received from OpenAI." }
    end

  rescue OpenAI::Error => e
    Rails.logger.error "❌ OpenAI API Error: #{e.message}"
    handle_openai_error(e)
  rescue StandardError => e
    Rails.logger.error "❌ Unexpected error in OpenAI service: #{e.message}"
    { error: "Une erreur inattendue s'est produite lors de l'analyse. Veuillez réessayer." }
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
      You are an expert in dream interpretation, specialized in psychological and symbolic analysis.

      Your role:
      - Analyze the dream with empathy and psychological depth.
      - Identify key symbols, emotions, and themes.
      - Provide interpretations and gentle suggestions based on dream psychology.
      - If the user's personality profile is available, take it into account.

      Instructions:
      - Respond strictly in the same language as the dream transcription. Do not translate or switch languages.
      - Your response must be a valid JSON object, and nothing else.
      - Use the following keys:
        - "symbols": symbolic interpretation of dream elements
        - "emotions": emotional tone and feelings expressed in the dream
        - "interpretation": general psychological meaning of the dream
        - "suggestions": gentle, practical advice for the dreamer
      - Each value should be a single paragraph of 3–6 sentences.
      - Do not add any Markdown, emojis, titles, or explanatory text before or after the JSON object.
      - Use compassionate, non-judgmental language, as if speaking to a friend seeking insight.
      - Avoid absolute statements; prefer "may suggest", "might indicate", etc.

      Example output (in French if the dream is in French):

      {
        "symbols": "L'eau qui monte peut symboliser une émotion refoulée qui devient difficile à contenir...",
        "emotions": "Une angoisse diffuse est présente tout au long du rêve, suggérant un sentiment d'insécurité...",
        "interpretation": "Ce rêve pourrait refléter un conflit intérieur lié à un événement récent...",
        "suggestions": "Il peut être utile de prendre un moment pour réfléchir aux émotions actuelles et en parler à un proche..."
      }
    PROMPT
  end

  def user_message
    message = <<~MSG.strip
      Please analyze the following dream:

      "#{@transcription.content}"
    MSG

    if @personality.present?
      message += "\n\n" + personality_context
    end

    message
  end

  def personality_context
    context = "Dreamer's profile:\n"
    context += "- Age: #{@personality.age} years\n" if @personality.age.present?
    context += "- Gender: #{@personality.gender}\n" if @personality.gender.present?
    context += "- Job: #{@personality.job}\n" if @personality.job.present?
    context += "- Current mood: #{@personality.mood}\n" if @personality.mood.present?
    context += "- Relationship status: #{@personality.relationship}\n" if @personality.relationship.present?
    context += "- Personal description: #{@personality.description}\n" if @personality.description.present?
    context += "\nPlease adapt the analysis considering this personal profile."
    context
  end

  def handle_openai_error(error)
    case error
    when OpenAI::RequestError
      if error.message.include?("rate_limit")
        { error: "Le service d'analyse est temporairement surchargé. Veuillez réessayer dans quelques minutes." }
      elsif error.message.include?("insufficient_quota")
        { error: "Le quota d'analyse a été atteint. Veuillez contacter l'administrateur." }
      else
        { error: "Erreur lors de la connexion au service d'analyse. Vérifiez votre connexion internet." }
      end
    when OpenAI::TimeoutError
      { error: "Le service d'analyse met trop de temps à répondre. Veuillez réessayer." }
    else
      { error: "Service d'analyse temporairement indisponible. Veuillez réessayer plus tard." }
    end
  end

  def detect_language(text)
    prompt = <<~PROMPT.strip
      What is the language of the following text? Respond only with the ISO 639-1 language code, like "fr", "en", or "es".

      "#{text}"
    PROMPT

    response = @client.chat(
      parameters: {
        model: "gpt-3.5-turbo",
        messages: [
          { role: "user", content: prompt }
        ],
        temperature: 0,
        max_tokens: 5
      }
    )

    lang = response.dig("choices", 0, "message", "content")&.strip&.downcase
    lang.match?(/^[a-z]{2}$/) ? lang : nil

  rescue => e
    Rails.logger.error "❌ Language detection failed: #{e.message}"
    nil
  end
end
