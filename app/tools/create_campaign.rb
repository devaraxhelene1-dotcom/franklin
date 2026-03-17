class CreateCampaign < RubyLLM::Tool
  attr_accessor :chat, :user

  description "Créer une campagne marketing après validation explicite de l'utilisateur."

  param :title, desc: "Titre court de la campagne"
  param :doc_content, desc: "Résumé fidèle de la doc produit fournie par l'utilisateur"
  param :icp, desc: "2-3 ICP validés, un par ligne séparés par \\n"
  param :channels, desc: "2-4 channels validés, un par ligne séparés par \\n"
  param :angles, desc: "2-3 angles validés, un par ligne séparés par \\n"

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

    # Essayer split par virgule (seulement si chaque partie est un item indépendant : court + commence par majuscule)
    parts = single.split(/\s*,\s*/)
    if parts.length >= 2 && parts.all? { |p| p.length < 80 && p.strip.match?(/\A[A-ZÀ-Ü]/) }
      return parts.map { |p| p.gsub(/\A[-–•\d.)\s]+/, "").strip }.reject(&:empty?).join("\n")
    end

    # Pas de pattern reconnu, retourner tel quel nettoyé
    single.gsub(/\A[-–•\d.)\s]+/, "").strip
  end
end
