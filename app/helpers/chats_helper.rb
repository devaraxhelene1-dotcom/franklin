module ChatsHelper
  def render_strategy_card(content)
    render partial: "chats/strategy_card", locals: { content: content, chat: @chat }
  end
end
