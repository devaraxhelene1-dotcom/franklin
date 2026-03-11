class GenerateCampaignSteps < RubyLLM::Tool
  attr_accessor :chat

  description "Générer le plan d'action marketing jour par jour pour une campagne validée. " \
              "Appelle cet outil juste après la création de la campagne. " \
              "Génère entre 5 et 8 steps (actions concrètes) répartis intelligemment sur 14 jours (day 1 à 14). " \
              "Chaque step contient le contenu complet : le channel utilisé, le texte/contenu à poster, " \
              "et les instructions précises pour l'utilisateur (quoi faire, comment, pourquoi). " \
              "Répartir les steps de manière stratégique sur les 14 jours (pas forcément consécutifs)."

  param :steps, type: :array, desc: "Liste de 5 à 8 steps. Chaque step est un objet avec 'day' (integer entre 1 et 14) et 'generated_content' (string avec le channel, le contenu à poster et les instructions pour l'utilisateur). Les steps doivent être en français."

  def execute(steps:)
    campaign = @chat.campaign

    return { error: "Aucune campagne liée à ce chat." } unless campaign

    steps.each do |step_data|
      campaign.steps.create!(
        day: step_data["day"],
        generated_content: step_data["generated_content"],
        status: "pending"
      )
    end

    campaign.update!(status: "active")

    { result: "#{steps.size} actions créées pour la campagne '#{campaign.title}' sur 14 jours. La campagne est maintenant active." }
  end
end
