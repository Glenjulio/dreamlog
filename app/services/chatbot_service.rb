# app/services/chatbot_service.rb
class ChatbotService
  include ActiveModel::Model

  attr_accessor :conversation, :user_message

  def initialize(conversation:, user_message:)
    @conversation = conversation
    @user_message = user_message
    validate_inputs!
    setup_client
  end

  def call
    Rails.logger.info "🤖 Generating AI response for conversation #{@conversation.id}"

    # Crée le message utilisateur
    user_msg = @conversation.messages.create!(
      role: 'user',
      content: @user_message
    )

    # Appel à l'API OpenAI
    response = @client.chat(
      parameters: {
        model: "gpt-4",
        temperature: 0.7,
        max_tokens: 1000,
        messages: build_messages
      }
    )

    assistant_content = response.dig("choices", 0, "message", "content")
    Rails.logger.info "✅ AI response generated successfully"

    # Crée le message assistant
    assistant_msg = @conversation.messages.create!(
      role: 'assistant',
      content: assistant_content,
      metadata: {
        model: "gpt-4",
        tokens: response.dig("usage", "total_tokens")
      }
    )

    { user_message: user_msg, assistant_message: assistant_msg }

  rescue OpenAI::Error => e
    Rails.logger.error "❌ OpenAI API Error: #{e.message}"
    handle_openai_error(e)
  rescue StandardError => e
    Rails.logger.error "❌ Unexpected error in Chatbot service: #{e.message}"
    { error: "Une erreur inattendue s'est produite. Veuillez réessayer." }
  end

  private

  def validate_inputs!
    raise ArgumentError, "Conversation is required" if @conversation.nil?
    raise ArgumentError, "User message is required" if @user_message.blank?
    raise ArgumentError, "User message is too short" if @user_message.length < 1
  end

  def setup_client
    api_key = ENV['OPENAI_API_KEY']
    raise ArgumentError, "OPENAI_API_KEY not configured" if api_key.blank?

    @client = OpenAI::Client.new(access_token: api_key)
  end

  def build_messages
    # Récupère l'historique complet de la conversation
    messages = [{ role: "system", content: system_prompt }]

    @conversation.messages.chronological.each do |msg|
      messages << { role: msg.role, content: msg.content }
    end

    messages
  end

  def system_prompt
    <<~PROMPT.strip
      Tu es un assistant AI bienveillant et intelligent intégré dans DreamLog,
      une application d'analyse de rêves.

      Ton rôle :
      - Aider l'utilisateur avec ses questions sur ses rêves
      - Fournir des analyses psychologiques et symboliques
      - Être empathique, positif et encourageant
      - Répondre dans la langue de l'utilisateur

      Contexte utilisateur :
      #{user_context}

      Sois naturel, concis et engageant dans tes réponses.
    PROMPT
  end

  def user_context
    user = @conversation.user
    context = "- Prénom : #{user.first_name}\n"

    if user.personality.present?
      personality = user.personality
      context += "- Âge : #{personality.age}\n" if personality.age.present?
      context += "- Profession : #{personality.job}\n" if personality.job.present?
      context += "- Description : #{personality.description}\n" if personality.description.present?
    end

    context
  end

  def handle_openai_error(error)
    case error
    when OpenAI::RequestError
      if error.message.include?("rate_limit")
        { error: "Le service chatbot est temporairement surchargé. Veuillez réessayer dans quelques minutes." }
      elsif error.message.include?("insufficient_quota")
        { error: "Le quota d'utilisation a été atteint. Veuillez contacter l'administrateur." }
      else
        { error: "Erreur lors de la connexion au service chatbot. Vérifiez votre connexion internet." }
      end
    when OpenAI::TimeoutError
      { error: "Le service chatbot met trop de temps à répondre. Veuillez réessayer." }
    else
      { error: "Service chatbot temporairement indisponible. Veuillez réessayer plus tard." }
    end
  end
end
