# app/controllers/messages_controller.rb
class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation

  # POST /conversations/:conversation_id/messages
  def create
    user_message = message_params[:content]

    if user_message.blank?
      redirect_to conversation_path(@conversation), alert: "Le message ne peut pas être vide."
      return
    end

    # Appel au service ChatbotService
    result = ChatbotService.new(
      conversation: @conversation,
      user_message: user_message
    ).call

    if result[:error]
      redirect_to conversation_path(@conversation), alert: result[:error]
    else
      redirect_to conversation_path(@conversation), notice: "Message envoyé avec succès."
    end

  rescue StandardError => e
    Rails.logger.error "❌ Error in MessagesController#create: #{e.message}"
    redirect_to conversation_path(@conversation), alert: "Une erreur est survenue. Veuillez réessayer."
  end

  private

  def set_conversation
    @conversation = current_user.conversations.find(params[:conversation_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to conversations_path, alert: "Conversation introuvable."
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
