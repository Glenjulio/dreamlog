class Analysis < ApplicationRecord
  belongs_to :transcription

  validates :data, presence: true

  # Optionnel : méthode pour fallback sur `content` si existant
  def legacy?
    data.blank? && content.present?
  end
end
