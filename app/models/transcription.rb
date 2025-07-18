class Transcription < ApplicationRecord
  belongs_to :dream
  has_many :analyzes, dependent: :destroy

  validates :content, presence: true, length: { minimum: 5, maximum: 10000 }
  validates :dream, presence: true
  validates :mood, length: { maximum: 50 }, allow_blank: true
  validates :tag, length: { maximum: 100 }, allow_blank: true
  validates :rating, numericality: { in: 1..10 }, allow_nil: true
end
