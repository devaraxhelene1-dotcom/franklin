class Step < ApplicationRecord
  belongs_to :campaign
  has_one_attached :image

  validates :day, presence: true, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: %w[pending done] }

  scope :done, -> { where(status: "done") }

  CHANNELS = [
    "LinkedIn", "Email", "Twitter / X", "Instagram",
    "TikTok", "Facebook", "Blog / Article", "Forum / Reddit", "Slack / Discord", "Autre"
  ].freeze

  # Parse generated_content (markdown format) into 3 structured fields.
  # Mirrors parseStepContent() in campaign_journey_controller.js.
  # Falls back to raw content in :content if format not recognized.
  def parse_content
    raw = generated_content.to_s
    parts = raw.split(/\n(?=\*\*\w)/m)

    channel      = nil
    content      = ""
    instructions = ""

    parts.each do |part|
      if (m = part.match(/\A\*\*Channel\*\*\s*[:\-]?\s*(.+)/i))
        channel = m[1].strip
      elsif (m = part.match(/\A\*\*Contenu[^*]*\*\*\s*[:\-]?\s*([\s\S]+)/i))
        content = m[1].strip
      elsif (m = part.match(/\A\*\*Instructions?\*\*\s*[:\-]?\s*([\s\S]+)/i))
        instructions = m[1].strip
      end
    end

    # Fallback: unrecognized format → put everything in content
    content = raw if content.blank? && channel.nil?

    { channel: channel.to_s, content: content, instructions: instructions }
  end

  # Reassemble 3 structured fields into the markdown format
  # expected by parseStepContent() in JS.
  def self.assemble_content(channel:, content:, instructions:)
    parts = []
    parts << "**Channel** : #{channel.strip}"          if channel.present?
    parts << "**Contenu à poster** :\n#{content.strip}" if content.present?

    if instructions.present?
      lines = instructions.split("\n").map(&:strip).reject(&:empty?)
      numbered = lines.each_with_index.map do |line, i|
        line.match?(/\A\d+\./) ? line : "#{i + 1}. #{line}"
      end.join("\n")
      parts << "**Instructions** :\n#{numbered}"
    end

    parts.join("\n\n")
  end
end
