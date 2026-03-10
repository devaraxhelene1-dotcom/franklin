class Chat < ApplicationRecord
  belongs_to :user
  belongs_to :campaign
  has_many :messages, dependent: :destroy

  validates :title, presence: true
end
