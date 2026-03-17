class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    if user_signed_in?
      chat = current_user.chats.order(created_at: :desc).first || current_user.chats.create!(title: "New Chat")
      redirect_to chat_path(chat)
    end
  end

  def dashboard
    @active_campaigns_count = current_user.campaigns.where(status: "active").count
    @completed_campaigns_count = current_user.campaigns.where(status: "completed").count
    @last_campaign = current_user.campaigns.order(created_at: :desc).first
    @pending_steps_count = @last_campaign&.steps&.where(status: "pending")&.count || 0
  end
end
