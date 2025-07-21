# app/services/open_ai_service.rb
require "openai"

class OpenAiService
  def initialize(transcription:, personality:)
    @transcription = transcription
    @personality = personality
    @client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
  end

  def call
    response = @client.chat(
      parameters: {
        model: "gpt-4",
        temperature: 0.7,
        messages: build_messages
      }
    )

    response.dig("choices", 0, "message", "content")
  end

  private

  def build_messages
    system_prompt = <<~PROMPT.strip
      Tu es un expert en interprétation des rêves, combinant des connaissances en psychologie et en analyse symbolique.
      Tu reçois une transcription de rêve, parfois accompagnée d'informations personnelles sur le rêveur (âge, métier, genre, etc.).
      Fournis une analyse approfondie et empathique du rêve, en expliquant les symboles clés, les émotions exprimées, et les thèmes récurrents éventuels.
    PROMPT

    user_message = <<~MSG.strip
      Voici le rêve à analyser :

      #{@transcription.content}

      #{"\n\nProfil du rêveur :\n" + personality_summary if @personality}
    MSG

    [
      { role: "system", content: system_prompt },
      { role: "user", content: user_message }
    ]
  end

  def personality_summary
    <<~TXT
      Âge : #{@personality.age}
      Genre : #{@personality.gender}
      Profession : #{@personality.job}
      Humeur actuelle : #{@personality.mood.presence || "non précisée"}
      Relation sentimentale : #{@personality.relationship.presence || "non précisée"}
      Description : #{@personality.description.presence || "non précisée"}
    TXT
  end
end
