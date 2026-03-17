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
    campaigns = current_user.campaigns
    @total_campaigns     = campaigns.count
    @active_campaigns    = campaigns.where(status: "active").count
    @completed_campaigns = campaigns.where(status: "completed").count
    @draft_campaigns     = campaigns.where(status: "draft").count

    all_steps    = Step.where(campaign: campaigns)
    @total_steps = all_steps.count
    @done_steps  = all_steps.where(status: "done").count

    @recent_campaigns   = campaigns.where.not(status: :draft).order(created_at: :desc).limit(5)
    @steps_per_campaign = @recent_campaigns.map do |c|
      done  = c.steps.where(status: "done").count
      total = c.steps.count
      { name: c.title, done: done, pending: total - done }
    end
  end
end
