require "open-uri"
require "stringio"

class GenerateCampaignImage < RubyLLM::Tool
  attr_accessor :chat

  description "Générer UNE image pour la campagne. " \
              "Appelle ce tool UNE SEULE FOIS par campagne, pour le premier step visuel uniquement. " \
              "Ne JAMAIS proposer de vidéo — uniquement des images statiques. " \
              "L'image sera générée par IA et attachée directement au step."

  param :day, type: :integer, desc: "Le numéro du jour (1 à 14) du step auquel attacher l'image"
  param :prompt,
        desc: "Description détaillée de l'image à générer en anglais. Sois précis sur le style, les couleurs, le sujet."

  def execute(day:, prompt:)
    campaign = @chat.campaign
    return { error: "Aucune campagne liée à ce chat." } unless campaign

    step = campaign.steps.find_by(day: day)
    return { error: "Step introuvable pour le jour #{day}." } unless step

    Rails.logger.info("=== IMAGE GENERATION START === Day: #{day}, Prompt: #{prompt.first(80)}...")

    client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY", nil))

    response = client.images.generate(
      parameters: {
        model: "gpt-image-1",
        prompt: prompt,
        n: 1,
        size: "1024x1024"
      }
    )

    Rails.logger.info("=== IMAGE API RESPONSE keys === #{response.dig('data', 0)&.keys}")

    # L'API gpt-image-1 retourne du base64 (b64_json), pas une URL
    b64_data = response.dig("data", 0, "b64_json")
    image_url = response.dig("data", 0, "url")

    if b64_data
      image_io = StringIO.new(Base64.decode64(b64_data))
      step.image.attach(
        io: image_io,
        filename: "step_#{step.id}_day_#{step.day}.png",
        content_type: "image/png"
      )
    elsif image_url
      image_file = URI.parse(image_url).open
      step.image.attach(
        io: image_file,
        filename: "step_#{step.id}_day_#{step.day}.png",
        content_type: "image/png"
      )
    else
      return { error: "Échec de la génération d'image." }
    end

    Rails.logger.info("=== IMAGE ATTACHED === Step #{step.id} Day #{step.day}")
    { result: "Image générée et attachée au step jour #{step.day}." }
  rescue StandardError => e
    Rails.logger.error("=== IMAGE GENERATION ERROR === #{e.class}: #{e.message}")
    { error: "Erreur lors de la génération d'image pour le jour #{day}: #{e.message}" }
  end
end
