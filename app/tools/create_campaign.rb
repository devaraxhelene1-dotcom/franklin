class CreateCampaign < RubyLLM::Tool
  attr_accessor :chat, :user

  description "Créer une campagne marketing après validation par l'utilisateur. " \
              "Appelle cet outil UNIQUEMENT quand l'utilisateur a explicitement validé les ICP, channels et angles proposés. " \
              "Ne jamais appeler cet outil sans validation claire de l'utilisateur. " \
              "Les ICP, channels et angles doivent avoir été discutés et approuvés dans le chat avant l'appel."

  param :title, desc: "Titre court et percutant de la campagne marketing"
  param :doc_content, desc: "Résumé fidèle de la documentation produit/service fournie par l'utilisateur (ne rien inventer, reprendre les infos du user)"
  param :icp, desc: "Ideal Customer Profiles validés (2 à 3 profils). Format: liste des profils avec pour chacun le rôle, le secteur, les douleurs et les objectifs"
  param :channels, desc: "Channels marketing validés (2 à 4). Doit toujours inclure LinkedIn + au moins une communauté ou forum de niche pertinent pour le produit"
  param :angles, desc: "Angles marketing validés (2 à 3). Les messages clés et approches de communication pour la campagne"

  def execute(title:, doc_content:, icp:, channels:, angles:)
    campaign = Campaign.create!(
      title: title,
      doc_content: doc_content,
      icp: icp,
      channels: channels,
      angles: angles,
      status: "draft",
      user: @user
    )

    @chat.update!(campaign: campaign)

    { result: "Campagne '#{title}' créée avec succès. Tu peux maintenant générer les steps du plan d'action." }
  end
end
