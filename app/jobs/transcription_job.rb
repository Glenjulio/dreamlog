# app/jobs/transcription_job.rb
class TranscriptionJob < ApplicationJob
  queue_as :default

  def perform(dream)
    Rails.logger.info "🎤 Starting transcription job for dream #{dream.id}"

    # Vérification des prérequis
    unless dream.audio.attached?
      Rails.logger.error "No audio attached to dream #{dream.id}"
      return
    end

    if dream.transcription.present?
      Rails.logger.info "Transcription already exists for dream #{dream.id}"
      return
    end

    begin
      # Appel du service de transcription
      service = TranscriptionService.new(dream: dream)
      result = service.transcribe

      if result[:success]
        Rails.logger.info "Transcription completed for dream #{dream.id}"
      else
        Rails.logger.error "Transcription failed for dream #{dream.id}: #{result[:message]}"
      end

    rescue StandardError => e
      Rails.logger.error "Unexpected error in TranscriptionJob for dream #{dream.id}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")

      # Relancer le job avec délai si c'est une erreur temporaire
      if attempt_number < 3
        retry_job(wait: 30.seconds)
      end
    end
  end
end
