class CreateCampaign < RubyLLM::Tool
  attr_accessor :chat, :user

  description "Créer une campagne marketing après validation par l'utilisateur. " \
              "Appelle cet outil UNIQUEMENT quand l'utilisateur a explicitement validé les ICP, channels et angles proposés. " \
              "Ne jamais appeler cet outil sans validation claire de l'utilisateur. " \
              "Les ICP, channels et angles doivent avoir été discutés et approuvés dans le chat avant l'appel."

  param :title, desc: "Titre court et percutant de la campagne marketing"
  param :doc_content, desc: "Résumé fidèle de la documentation produit/service fournie par l'utilisateur (ne rien inventer, reprendre les infos du user)"
  param :icp, desc: "Ideal Customer Profiles validés (2 à 3 profils). " \
    "UN profil par ligne, séparés par des retours à la ligne \\n. " \
    "Chaque profil = titre court + rôle + contexte entre parenthèses. " \
    "Exemple : \"Gérant d'agence immo indépendante (1-10 pers.)\\nConsultant RH freelance (TPE/PME)\""
  param :channels, desc: "Channels marketing validés (2 à 4). " \
    "UN channel par ligne, séparés par des retours à la ligne \\n. " \
    "Juste le nom du channel, pas de justification. " \
    "Exemple : \"LinkedIn\\nReddit (r/fitness)\\nInstagram\""
  param :angles, desc: "Angles marketing validés (2 à 3). " \
    "UN angle par ligne, séparés par des retours à la ligne \\n. " \
    "Chaque angle = une phrase complète et concrète. " \
    "Exemple : \"Progresse sans coach, à ta façon\\nTon téléphone suffit, plus besoin de salle\""

  def execute(title:, doc_content:, icp:, channels:, angles:)
    campaign = Campaign.create!(
      title: title,
      doc_content: doc_content,
      icp: normalize_list(icp),
      channels: normalize_list(channels),
      angles: normalize_list(angles),
      status: "draft",
      user: @user
    )

    @chat.update!(campaign: campaign)

    { result: "Campagne '#{title}' créée avec succès. Tu peux maintenant générer les steps du plan d'action." }
  end

  private

  def normalize_list(raw)
    text = raw.to_s.strip

    # Si déjà multi-lignes propres, on nettoie juste les puces
    lines = text.split("\n").map(&:strip).reject(&:empty?)

    if lines.length >= 2
      # Déjà multi-lignes, juste nettoyer les puces/numéros
      return lines.map { |l| l.gsub(/\A[-–•\d.)\s]+/, "").strip }.reject(&:empty?).join("\n")
    end

    # Tout sur une ligne — splitter par ; ou par numérotation
    single = lines.first.to_s

    # Essayer split par ;
    parts = single.split(/\s*;\s*/)
    if parts.length >= 2
      return parts.map { |p| p.gsub(/\A[-–•\d.)\s]+/, "").strip }.reject(&:empty?).join("\n")
    end

    # Essayer split par numérotation inline (1. ... 2. ... ou - ... - ...)
    parts = single.split(/(?<=\S)\s+(?=\d+\.\s)/)
    if parts.length >= 2
      return parts.map { |p| p.gsub(/\A[-–•\d.)\s]+/, "").strip }.reject(&:empty?).join("\n")
    end

    # Essayer split par virgule (seulement pour les channels courts)
    parts = single.split(/\s*,\s*/)
    if parts.length >= 2 && parts.all? { |p| p.length < 80 }
      return parts.map { |p| p.gsub(/\A[-–•\d.)\s]+/, "").strip }.reject(&:empty?).join("\n")
    end

    # Pas de pattern reconnu, retourner tel quel nettoyé
    single.gsub(/\A[-–•\d.)\s]+/, "").strip
  end
end
