class Transcription < ApplicationRecord
  belongs_to :dream
  has_many :analyses
end
