class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    if user_signed_in?
      chat = current_user.chats.create!(title: "New Chat")
      redirect_to chat_path(chat)
    end
  end
end
