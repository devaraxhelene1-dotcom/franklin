class Campaign < ApplicationRecord
  belongs_to :user
  has_one :chat, dependent: :destroy
  has_many :steps, dependent: :destroy

  validates :title, presence: true
  validates :status, inclusion: { in: %w[draft active completed] }
  validates :icp, :channels, :angles, presence: true, if: -> { status != "draft" }
end
