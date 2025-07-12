class Dream < ApplicationRecord
  belongs_to :user
  has_one :transcription
end
