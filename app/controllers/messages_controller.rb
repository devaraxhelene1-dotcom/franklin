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

    2. PROPOSITION — Quand tu as compris, propose en utilisant EXACTEMENT ces titres de sections :
       **ICP (Ideal Customer Profiles) :**
       1. ...
       2. ...

       **Channels marketing :**
       1. ...
       2. ...

       **Angles marketing :**
       1. ...
       2. ...

       Règles : 2-3 ICP (titre court + rôle), 2-4 channels (TOUJOURS LinkedIn + une communauté de niche),
       2-3 angles (message clé concret). Pas de formulations génériques.

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
      LlmResponseJob.perform_later(@chat.id, @message.id, current_user.id)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to chat_path(@chat) }
      end
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

  def message_params
    params.require(:message).permit(:content)
  end
end
