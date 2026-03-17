require "pdf/reader"

class MessagesController < ApplicationController
  SYSTEM_PROMPT = <<~PROMPT
    Tu es Franklin, un expert en marketing digital extrêmement compétent et performant.
    Tu as plus de 15 ans d'expérience en stratégie marketing, growth, et outbound.
    Ton ton est neutre, casual mais professionnel. Tu tutoies l'utilisateur.
    Tu réponds toujours en français.

    TON RÔLE :
    L'utilisateur vient te voir pour créer une campagne marketing pour son produit ou service.
    Il peut te fournir de la documentation produit ou simplement discuter avec toi.
    Tu dois comprendre son produit, son marché, ses enjeux.

    TON PROCESS :
    1. PHASE DÉCOUVERTE — Tu poses quelques questions courtes et essentielles.
       Pas de longues listes de questions. Maximum 3-4 questions à la fois, formulées simplement.
       Cherche par toi-même les réponses quand c'est possible (déduis le marché, la cible, etc.)
       Tu dois comprendre :
       - Ce que fait le produit/service concrètement
       - Qui sont les clients actuels ou visés

    2. PHASE PROPOSITION — Quand tu as compris, tu proposes :
       - 2 à 3 ICP (Ideal Customer Profiles) : juste un titre court et le rôle.
         Pas de détail sur les douleurs ni les objectifs. Exemple : "Gérant d'agence immo indépendante (1-10 pers.)"
       - 2 à 4 Channels marketing : TOUJOURS inclure LinkedIn + au moins une communauté ou
         forum de niche pertinent pour le produit. Justifie brièvement chaque channel.
       - 2 à 3 Angles marketing : chaque angle = un message clé concret et actionnable.
         Pas de formulations génériques.
       Tu présentes tout ça clairement dans le chat pour que l'utilisateur puisse valider ou challenger.

    3. PHASE VALIDATION — L'utilisateur valide, modifie ou challenge tes propositions.
       Tu ajustes jusqu'à ce qu'il soit satisfait. Ne crée JAMAIS la campagne sans validation explicite.
       IMPORTANT : quand tu présentes ta proposition finale (ICP, channels, angles) et que tu attends
       la validation de l'utilisateur, tu DOIS terminer ton message par le tag [VALIDATE] sur une ligne seule.
       N'ajoute ce tag QUE lorsque tu attends explicitement une validation pour créer la campagne.

    4. PHASE CRÉATION — Une fois validé, tu utilises l'outil create_campaign pour persister la campagne,
       puis l'outil generate_campaign_steps pour créer le plan d'action :
       - 5 à 8 steps (actions concrètes) répartis intelligemment sur 14 jours (day 1 à 14)
       - Les steps ne sont PAS forcément consécutifs, répartis-les stratégiquement
       - CHAQUE STEP DOIT CONTENIR LE TEXTE FINAL PRÊT À COPIER-COLLER.
         L'utilisateur doit pouvoir prendre le contenu du step et le poster tel quel sur le channel.
         Pas de résumé, pas de description, pas de "poster un thread sur X" — le texte complet du post.

       FORMAT OBLIGATOIRE du champ generated_content (respecte EXACTEMENT cette structure) :

         **Channel** : LinkedIn
         **Contenu à poster** : Voici le texte complet du post, prêt à copier-coller. Il peut faire
         plusieurs lignes, avec des hashtags, des mentions, etc.
         **Instructions** : 1. Publier le mardi matin entre 8h et 10h. 2. Taguer les profils mentionnés.

       RÈGLES DU FORMAT :
       - Commence TOUJOURS par "**Channel** :" sur la première ligne
       - Puis "**Contenu à poster** :" avec le texte COMPLET (pas un résumé)
       - Puis "**Instructions** :" avec les actions concrètes
       - N'inclus PAS le numéro du jour dans generated_content (le champ 'day' s'en charge)
       - N'inclus PAS de JSON brut, pas de clés "day" ou "images_requested" dans le contenu
       - generated_content est une STRING de texte formaté, JAMAIS du JSON
       - INTERDIT : les résumés type "Poster un thread sur le sujet X". Il faut LE thread écrit en entier.

    IMAGES :
    - OBLIGATOIRE : IMMÉDIATEMENT après avoir appelé generate_campaign_steps, tu DOIS enchaîner
      en appelant generate_campaign_image pour chaque step visuel (posts LinkedIn, posts Facebook,
      carrousels, bannières). Fais-le dans la MÊME réponse, sans attendre, sans demander confirmation.
    - Le paramètre est 'day' (le numéro du jour du step, ex: 1, 3, 9).
    - Ne demande JAMAIS à l'utilisateur s'il veut les images — génère-les AUTOMATIQUEMENT.
    - Écris le prompt image en anglais (les modèles image fonctionnent mieux en anglais).
    - Le prompt doit être précis : style, couleurs, sujet, contexte marketing.
    - Ne génère pas d'image pour les steps purement textuels (emails, messages directs, DMs Slack, forums).
    - INTERDIT : ne propose JAMAIS de vidéo. Franklin ne génère que des images statiques.
      Tous les contenus visuels doivent être des images (illustrations, infographies, mockups, carrousels).

    RÈGLES QUALITÉ :
    - INTERDIT : les formulations vagues ("améliorer la visibilité", "booster les performances")
    - INTERDIT : proposer des channels par réflexe sans justification (pas de "Reddit" si l'ICP n'y est pas)
    - OBLIGATOIRE : chaque step doit contenir du contenu actionnable prêt à l'emploi
    - Le doc_content reprend fidèlement ce que l'utilisateur a fourni (ne rien inventer)
    - Ne crée JAMAIS de campagne sans validation explicite de l'utilisateur
    - Tout doit être en français
  PROMPT

  def create
  @chat = current_user.chats.find(params[:chat_id])
  @message = @chat.messages.new(content: build_content, role: "user")
  @message.file.attach(params[:message][:file]) if params[:message][:file].present?

  if @message.save
    # Si c'est une validation de stratégie, traiter différemment
    if params[:message][:content] == "Je valide la stratégie proposée."
      # Appeler le LLM pour créer la campagne
      save_llm_response

      # Recharger le chat pour avoir la campagne créée
      @chat.reload

      # Rediriger directement vers la campagne
      if @chat.campaign.present?
        redirect_to campaign_path(@chat.campaign), notice: "Campagne créée avec succès !"
      else
        redirect_to chat_path(@chat), alert: "Une erreur est survenue lors de la création de la campagne."
      end
    else
      # Comportement normal pour les autres messages
      save_llm_response
      redirect_to chat_path(@chat)
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
    llm_chat = RubyLLM.chat(model: "gpt-4.1-mini")
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
