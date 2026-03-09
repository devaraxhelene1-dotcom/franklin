class Project < ApplicationRecord
  belongs_to :user
  has_many :chats, dependent: :destroy
  has_many :campaigns, dependent: :destroy

  validates :title, presence: true
end
