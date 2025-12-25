# app/models/message.rb
class Message < ApplicationRecord
  # === Associations ===
  belongs_to :conversation

  # === Validations ===
  validates :conversation, presence: true
  validates :role, presence: true, inclusion: { in: %w[user assistant] }
  validates :content, presence: true, length: { minimum: 1 }

  # === Scopes ===
  scope :by_role, ->(role) { where(role: role) }
  scope :user_messages, -> { where(role: 'user') }
  scope :assistant_messages, -> { where(role: 'assistant') }
  scope :chronological, -> { order(created_at: :asc) }

  # === Callbacks ===
  after_create :update_conversation_timestamp

  # === Méthodes publiques ===

  # Vérifie si le message vient de l'utilisateur
  def from_user?
    role == 'user'
  end

  # Vérifie si le message vient de l'assistant
  def from_assistant?
    role == 'assistant'
  end

  # Retourne un extrait court du contenu
  def excerpt(length = 100)
    content.truncate(length)
  end

  private

  # Met à jour le timestamp de la conversation parent
  def update_conversation_timestamp
    conversation.touch
  end
end
