# app/controllers/conversations_controller.rb
class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: [:show, :destroy, :archive, :unarchive]

  # GET /conversations
  def index
    @conversations = current_user.conversations.active.recent
    @archived_conversations = current_user.conversations.archived.recent
  end

  # GET /conversations/:id
  def show
    @messages = @conversation.messages.chronological
    @new_message = Message.new
  end

  # POST /conversations
  def create
    @conversation = current_user.conversations.create!(title: "Nouvelle conversation")

    redirect_to conversation_path(@conversation), notice: "Conversation créée avec succès."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to conversations_path, alert: "Erreur lors de la création de la conversation."
  end

  # DELETE /conversations/:id
  def destroy
    @conversation.destroy
    redirect_to conversations_path, notice: "Conversation supprimée avec succès."
  end

  # PATCH /conversations/:id/archive
  def archive
    @conversation.archive!
    redirect_to conversations_path, notice: "Conversation archivée."
  end

  # PATCH /conversations/:id/unarchive
  def unarchive
    @conversation.unarchive!
    redirect_to conversations_path, notice: "Conversation restaurée."
  end

  private

  def set_conversation
    @conversation = current_user.conversations.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to conversations_path, alert: "Conversation introuvable."
  end
end
