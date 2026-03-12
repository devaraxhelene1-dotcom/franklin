class ChatsController < ApplicationController
  def show
    @chat = current_user.chats.find(params[:id])
    @message = Message.new
  end

  def create
    @chat = Chat.new(title: "Nouvelle campagne", user: current_user)
    if @chat.save
      redirect_to chat_path(@chat)
    else
      redirect_to root_path, alert: "Impossible de créer le chat."
    end
  end
end
