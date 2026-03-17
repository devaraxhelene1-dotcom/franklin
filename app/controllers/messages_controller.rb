require "pdf/reader"

class MessagesController < ApplicationController
  SYSTEM_PROMPT = <<~PROMPT
    Tu es Franklin, un expert en marketing digital avec 15+ ans d'expérience en stratégie, growth et outbound.
    Ton ton est neutre, casual mais professionnel. Tu tutoies. Tu réponds toujours en français.

    TON RÔLE :
    L'utilisateur veut créer une campagne marketing. Il peut fournir de la doc produit ou discuter.
    Tu dois comprendre son produit, son marché, ses enjeux.

    TON PROCESS :
    1. DÉCOUVERTE — Pose quelques questions courtes (max 3-4 à la fois).
       Déduis ce que tu peux. Tu dois comprendre :
       - Ce que fait le produit/service
       - Qui sont les clients actuels ou visés

    2. PROPOSITION — Quand tu as compris, propose :
       - 2-3 ICP : titre court + rôle. Pas de détail douleurs/objectifs.
       - 2-4 Channels : TOUJOURS LinkedIn + au moins une communauté de niche. Justifie brièvement.
       - 2-3 Angles : message clé concret et actionnable. Pas de formulations génériques.
       Présente tout clairement pour validation.

    3. VALIDATION — L'utilisateur valide, modifie ou challenge.
       Ne crée JAMAIS la campagne sans validation explicite.
       Quand tu présentes ta proposition finale et attends validation,
       termine ton message par le tag [VALIDATE] sur une ligne seule.

    4. CRÉATION — Une fois validé, enchaîne les 3 appels suivants DANS LA MÊME RÉPONSE, sans rien demander :
       a) Appelle create_campaign pour persister la campagne.
       b) Appelle generate_campaign_steps avec 4 à 7 steps répartis stratégiquement sur 14 jours.
          Chaque step DOIT contenir le texte FINAL prêt à copier-coller (pas de résumé).
       c) Appelle generate_campaign_image pour le premier step LinkedIn.
       Ne pose AUCUNE question entre ces étapes. Fais tout d'un coup.

    RÈGLES :
    - Pas de formulations vagues ("améliorer la visibilité", "booster les performances")
    - Le doc_content reprend fidèlement ce que l'utilisateur a fourni
    - Tout en français (sauf les prompts image, en anglais)
  PROMPT

  def create
    @chat = current_user.chats.find(params[:chat_id])
    @message = @chat.messages.new(content: build_content, role: "user")
    @message.file.attach(params[:message][:file]) if params[:message][:file].present?

    if @message.save
      save_llm_response
      redirect_to chat_path(@chat)
    else
      render "chats/show", status: :unprocessable_entity
    end
  end

  private

  def build_content
    content = params[:message][:content].to_s
    return content unless params[:message][:file].present?

    file = params[:message][:file]
    ext = File.extname(file.original_filename).downcase

    case ext
    when ".pdf"
      reader = PDF::Reader.new(file.tempfile)
      text = reader.pages.map(&:text).join("\n")
      "#{content}\n\n--- Document PDF fourni par l'utilisateur ---\n#{text}"
    when ".jpg", ".jpeg", ".png"
      content.presence || "J'ai joint une image."
    else
      file_text = file.read.force_encoding("UTF-8")
      "#{content}\n\n--- Document fourni par l'utilisateur ---\n#{file_text}"
    end
  end

  def image_upload?
    return false unless params[:message][:file].present?

    ext = File.extname(params[:message][:file].original_filename).downcase
    %w[.jpg .jpeg .png].include?(ext)
  end

  def save_llm_response
    response = call_llm
    @chat.messages.create!(role: "assistant", content: response.content)
  rescue StandardError => e
    @chat.messages.create!(
      role: "assistant",
      content: "Désolé, une erreur est survenue (#{e.message}). Réessaie dans quelques instants."
    )
  end

  def call_llm
    llm_chat = RubyLLM.chat(model: "gpt-4.1")
    llm_chat.with_instructions(SYSTEM_PROMPT)

    # Passer des instances de tools avec le contexte injecté (chat + user)
    create_campaign_tool = CreateCampaign.new
    create_campaign_tool.chat = @chat
    create_campaign_tool.user = current_user

    generate_steps_tool = GenerateCampaignSteps.new
    generate_steps_tool.chat = @chat

    generate_image_tool = GenerateCampaignImage.new
    generate_image_tool.chat = @chat

    llm_chat.with_tools(create_campaign_tool, generate_steps_tool, generate_image_tool)

    # Injecter l'historique SANS appeler le LLM à chaque message
    # add_message préserve les rôles (user/assistant) et ne génère aucune réponse
    previous_messages = @chat.messages.order(:created_at).where.not(id: @message.id)
    previous_messages.each do |msg|
      llm_chat.add_message(role: msg.role.to_sym, content: msg.content)
    end

    # Seul le dernier message (celui qu'on vient de créer) déclenche un appel au LLM
    if @message.file.attached? && @message.file.content_type&.start_with?("image/")
      blob = @message.file.blob
      base64 = Base64.strict_encode64(blob.download)
      llm_chat.ask(@message.content, with: { image: "data:#{blob.content_type};base64,#{base64}" })
    else
      llm_chat.ask(@message.content)
    end
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
