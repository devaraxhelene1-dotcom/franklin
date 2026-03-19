class LlmResponseJob < ApplicationJob
  queue_as :default

  SYSTEM_PROMPT = MessagesController::SYSTEM_PROMPT

  def perform(chat_id, message_id, user_id)
    @chat = Chat.find(chat_id)
    @message = Message.find(message_id)
    @user = User.find(user_id)

    response = call_llm
    assistant_message = @chat.messages.create!(role: "assistant", content: response.content)

    broadcast_response(assistant_message)
    handle_campaign_redirect
  rescue StandardError => e
    assistant_message = @chat.messages.create!(
      role: "assistant",
      content: "Désolé, une erreur est survenue (#{e.message}). Réessaie dans quelques instants."
    )
    broadcast_response(assistant_message)
  end

  private

  def call_llm
    llm_chat = RubyLLM.chat(model: "gpt-4.1")
    llm_chat.with_instructions(SYSTEM_PROMPT)

    create_campaign_tool = CreateCampaign.new
    create_campaign_tool.chat = @chat
    create_campaign_tool.user = @user

    generate_steps_tool = GenerateCampaignSteps.new
    generate_steps_tool.chat = @chat

    # generate_image_tool = GenerateCampaignImage.new
    # generate_image_tool.chat = @chat

    llm_chat.with_tools(create_campaign_tool, generate_steps_tool)

    previous_messages = @chat.messages.order(:created_at).where.not(id: @message.id)
    previous_messages.each do |msg|
      llm_chat.add_message(role: msg.role.to_sym, content: msg.content)
    end

    if @message.file.attached? && @message.file.content_type&.start_with?("image/")
      blob = @message.file.blob
      base64 = Base64.strict_encode64(blob.download)
      llm_chat.ask(@message.content, with: { image: "data:#{blob.content_type};base64,#{base64}" })
    else
      llm_chat.ask(@message.content)
    end
  end

  def broadcast_response(assistant_message)
    Turbo::StreamsChannel.broadcast_action_to(
      @chat,
      action: :replace,
      target: "loading-indicator",
      html: <<~HTML
        <div class="message message-bot d-none" id="loading-indicator" data-chat-target="loading">
          <img src="#{ActionController::Base.helpers.asset_path('Logo_Franklin.png')}" class="loading-logo-inline" alt="Franklin écrit..." />
        </div>
      HTML
    )

    Turbo::StreamsChannel.broadcast_action_to(
      @chat,
      action: :before,
      target: "loading-indicator",
      partial: "messages/message",
      locals: { message: assistant_message }
    )
  end

  def handle_campaign_redirect
    @chat.reload
    return unless @message.content == "Je valide la stratégie proposée." && @chat.campaign.present?

    campaign_url = Rails.application.routes.url_helpers.campaign_path(@chat.campaign)

    Turbo::StreamsChannel.broadcast_append_to(
      @chat,
      target: "chat_messages",
      html: <<~HTML
        <div data-controller="redirect" data-redirect-url-value="#{campaign_url}"></div>
      HTML
    )
  end
end
