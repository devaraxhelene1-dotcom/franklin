class Step < ApplicationRecord
  belongs_to :campaign

  validates :day, presence: true, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: %w[pending done] }

  scope :done, -> { where(status: "done") }
end
