# app/services/transcription_service.rb
class TranscriptionService
  include ActiveModel::Model

  attr_accessor :audio_file, :dream

  def initialize(dream:)
    @dream = dream
    @audio_file = dream.audio if dream.audio.attached?
    @client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
  end

  def transcribe
    return failure_result("No audio file attached") unless audio_file_present?
    return failure_result("Transcription already exists") if transcription_exists?

    begin
      # Créer un fichier temporaire pour Whisper
      temp_file = create_temp_audio_file

      # Appel à OpenAI Whisper
      response = @client.audio.transcribe(
        parameters: {
          model: "whisper-1",
          file: temp_file
        }
      )

      # Créer la transcription
      transcription = create_transcription(response["text"])

      # Nettoyer le fichier temporaire
      cleanup_temp_file(temp_file)

      success_result(transcription)

    rescue => e
      cleanup_temp_file(temp_file) if temp_file
      failure_result("Transcription failed: #{e.message}")
    end
  end

  private

  def audio_file_present?
    audio_file.present? && audio_file.attached?
  end

  def transcription_exists?
    @dream.transcription.present?
  end

  def create_temp_audio_file
    # Créer un fichier temporaire avec l'extension appropriée
    temp_file = Tempfile.new(['audio', file_extension])
    temp_file.binmode

    # copier le contenu du fichier audio attaché dans le fichier temporaire
    audio_file.open do |file|
      temp_file.write(file.read)
    end

    temp_file.rewind
    temp_file
  end

  def file_extension
    case audio_file.content_type
    when 'audio/webm'
      '.webm'
    when 'audio/mp3', 'audio/mpeg'
      '.mp3'
    when 'audio/wav'
      '.wav'
    when 'audio/m4a'
      '.m4a'
    else
      '.webm'
    end
  end

  def create_transcription(text)
    @dream.create_transcription!(
      content: text.strip,
      mood: extract_mood(text),
      tag: "whisper_generated"
    )
  end

  def extract_mood(text)
    case text.downcase
    when /happy|joy|content|pleased|cheerful/
      "positive"
    when /sad|depressed|unhappy|melancholy/
      "negative"
    when /fear|scared|anxious|worried|nightmare/
      "anxious"
    when /angry|furious|mad|irritated/
      "angry"
    else
      "neutral"
    end
  end

  def cleanup_temp_file(temp_file)
    temp_file&.close
    temp_file&.unlink
  end

  def success_result(transcription)
    {
      success: true,
      transcription: transcription,
      message: "Transcription completed successfully"
    }
  end

  def failure_result(message)
    {
      success: false,
      transcription: nil,
      message: message
    }
  end
end
