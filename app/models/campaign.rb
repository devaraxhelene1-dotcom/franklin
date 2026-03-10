class Campaign < ApplicationRecord
  belongs_to :user
  has_many :steps, dependent: :destroy
  has_one_attached :image

  validates :title, presence: true
  validates :status, inclusion: { in: %w[draft active completed] }
end
