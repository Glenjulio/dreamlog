class Dream < ApplicationRecord
  belongs_to :user
  has_one :transcription, dependent: :destroy
  has_one_attached :audio
  accepts_nested_attributes_for :transcription, allow_destroy: true

  validates :title, presence: true, length: { minimum: 3, maximum: 200 }
  validates :user, presence: true

  enum status: {
    draft: 'draft',
    recording: 'recording',
    transcribing: 'transcribing',
    completed: 'completed'
  }

  scope :public_dreams, -> { where(private: [false, nil]) }
  scope :private_dreams, -> { where(private: true) }
end
