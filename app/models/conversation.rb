# app/models/conversation.rb
class Conversation < ApplicationRecord
  # === Associations ===
  belongs_to :user
  has_many :messages, dependent: :destroy

  # === Validations ===
  validates :user, presence: true

  # === Scopes ===
  scope :active, -> { where(archived: false) }
  scope :archived, -> { where(archived: true) }
  scope :recent, -> { order(updated_at: :desc) }

  # === Callbacks ===
  before_create :generate_title

  # === Méthodes publiques ===

  # Archive la conversation
  def archive!
    update(archived: true)
  end

  # Restaure une conversation archivée
  def unarchive!
    update(archived: false)
  end

  # Retourne le dernier message de la conversation
  def last_message
    messages.order(created_at: :desc).first
  end

  # Retourne un résumé de la conversation (premiers mots du 1er message user)
  def summary
    first_user_message = messages.where(role: 'user').order(created_at: :asc).first
    return 'Nouvelle conversation' unless first_user_message

    first_user_message.content.truncate(50)
  end

  private

  # Génère un titre par défaut basé sur la date
  def generate_title
    self.title ||= "Conversation du #{I18n.l(Time.current, format: :short)}"
  end
end
