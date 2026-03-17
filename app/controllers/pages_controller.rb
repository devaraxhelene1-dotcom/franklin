class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    if user_signed_in?
      chat = current_user.chats.order(created_at: :desc).first ||
             current_user.chats.create!(title: "Nouvelle campagne")
      redirect_to chat_path(chat)
    end
  end

  def dashboard
    @active_campaigns_count    = current_user.campaigns.where(status: "active").count
    @completed_campaigns_count = current_user.campaigns.where(status: "completed").count
    @last_campaign             = current_user.campaigns.order(created_at: :desc).first
    @pending_steps_count       = @last_campaign&.steps&.where(status: "pending")&.count || 0
  end

  def calendar
    @active_campaigns = current_user.campaigns.where(status: "active").includes(:steps).order(:title)

    @start_date = Date.current.beginning_of_week(:monday)
    @end_date = @start_date + 27.days

    @calendar_steps = {}
    (@start_date..@end_date).each { |d| @calendar_steps[d] = [] }

    @active_campaigns.each do |campaign|
      campaign.steps.each do |step|
        real_date = campaign.created_at.to_date + (step.day - 1).days
        next unless @calendar_steps.key?(real_date)

        parsed = step.parse_content
        @calendar_steps[real_date] << { step: step, campaign: campaign, channel: parsed[:channel] }
      end
    end
  end
end
