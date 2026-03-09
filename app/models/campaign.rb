class Campaign < ApplicationRecord
  belongs_to :project
  has_many :steps, dependent: :destroy

  validates :title, presence: true
  validates :status, inclusion: { in: %w[draft active completed] }
end
