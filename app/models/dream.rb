class Dream < ApplicationRecord
  belongs_to :user
  has_one :transcription, dependent: :destroy

  accepts_nested_attributes_for :transcription
end
