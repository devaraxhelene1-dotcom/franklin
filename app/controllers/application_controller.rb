class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_sidebar_campaigns

  private

  def after_sign_in_path_for(resource)
    chat = resource.chats.create!(title: "Nouvelle campagne")
    chat_path(chat)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
  end

  def set_sidebar_campaigns
    @campaigns = current_user.campaigns.where.not(status: :draft).order(created_at: :desc).limit(10) if user_signed_in?
  end

end
