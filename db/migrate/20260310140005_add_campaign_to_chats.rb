class AddCampaignToChats < ActiveRecord::Migration[8.1]
  def change
    add_reference :chats, :campaign, foreign_key: true
  end
end
