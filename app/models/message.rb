class Message < ApplicationRecord
  belongs_to :chat
  has_one_attached :file

  validates :content, presence: true
  validates :role, inclusion: { in: %w[user assistant] }
end
