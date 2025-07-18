class Personality < ApplicationRecord
  belongs_to :user

  validates :age, presence: true, numericality: { greater_than: 0, less_than: 120 }
  validates :job, presence: true, length: { minimum: 2, maximum: 100 }
  validates :gender, presence: true, length: { maximum: 50 }
  validates :description, length: { maximum: 1000 }, allow_blank: true
  validates :relationship, length: { maximum: 100 }, allow_blank: true
  validates :mood, length: { maximum: 50 }, allow_blank: true
  validates :user, presence: true, uniqueness: true
end
