class Message < ApplicationRecord
  belongs_to :chat

  validates :content, presence: true
  validates :role, inclusion: { in: %w[user assistant] }
end
