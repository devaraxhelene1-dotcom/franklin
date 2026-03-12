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

    Rails.logger.info("=== STEPS RECEIVED ===")
    Rails.logger.info("Class: #{steps.class}")
    Rails.logger.info("Value: #{steps.inspect}")

    # Parser les steps si c'est une string JSON
    parsed_steps = steps.is_a?(String) ? JSON.parse(steps) : steps

    # Répartition par défaut si aucun jour n'est trouvé
    default_days = [1, 3, 5, 8, 10, 12, 14]

    created_count = 0
    parsed_steps.each_with_index do |step_data, index|
      day = nil
      content = nil

      if step_data.is_a?(Hash)
        data = step_data.with_indifferent_access
        day = data[:day]
        content = data[:generated_content]
      elsif step_data.is_a?(String)
        # Le LLM peut envoyer des JSON stringifiés ou des strings libres
        begin
          parsed = JSON.parse(step_data)
          if parsed.is_a?(Hash)
            parsed = parsed.with_indifferent_access
            day = parsed[:day]
            content = parsed[:generated_content]
          end
        rescue JSON::ParserError
          # Fallback : extraire le jour depuis le texte "Day 3 : LinkedIn — ..." ou "Jour 3"
          day_match = step_data.match(/(?:Day|Jour)\s*(\d+)/i)
          day = day_match ? day_match.captures.first.to_i : nil
          content = step_data
        end
      else
        next
      end

      # Dernier recours : assigner un jour par défaut basé sur la position
      day ||= default_days[index] || (index + 1)

      next unless content.present?

      campaign.steps.create!(day: day, generated_content: content, status: "pending")
      created_count += 1
    end

    campaign.update!(status: "active")

    { result: "#{created_count} actions créées pour la campagne '#{campaign.title}' sur 14 jours. La campagne est maintenant active." }
  end
end
