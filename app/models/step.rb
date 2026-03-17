class Step < ApplicationRecord
  belongs_to :campaign
  has_one_attached :image

  validates :day, presence: true, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: %w[pending done] }

  scope :done, -> { where(status: "done") }

  CHANNELS = %w[Email LinkedIn Twitter Instagram TikTok SMS Blog].freeze

  # generated_content format:
  # CHANNEL: <channel>
  # ---
  # <content body>
  # ===INSTRUCTIONS===
  # <instructions>
  def parse_content
    raw = generated_content.to_s
    channel_match = raw.match(/\ACHANNEL:\s*(.+)\n---\n/m)
    channel = channel_match ? channel_match[1].strip : ""
    after_header = channel_match ? raw[channel_match.end(0)..] : raw
    parts = after_header.split("===INSTRUCTIONS===", 2)
    { channel: channel, content: parts[0].to_s.strip, instructions: parts[1].to_s.strip }
  end

  def self.assemble_content(channel:, content:, instructions:)
    text = "CHANNEL: #{channel}\n---\n#{content}"
    text += "\n===INSTRUCTIONS===\n#{instructions}" if instructions.present?
    text
  end
end
