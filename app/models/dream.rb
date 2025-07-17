class Dream < ApplicationRecord
  belongs_to :user
  has_one :transcription, dependent: :destroy
  accepts_nested_attributes_for :transcription

  validates :title, presence: true, length: { minimum: 3 }

  enum status: {
    draft: 'draft',
    recording: 'recording',
    transcribing: 'transcribing',
    completed: 'completed'
  }

  scope :public_dreams, -> { where(private: false) }
  scope :recent, -> { order(created_at: :desc) }
end
