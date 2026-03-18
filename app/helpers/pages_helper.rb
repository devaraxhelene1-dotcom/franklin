module PagesHelper
  CAMPAIGN_COLORS = %w[
    campaign-color-1 campaign-color-2 campaign-color-3 campaign-color-4
    campaign-color-5 campaign-color-6 campaign-color-7 campaign-color-8
  ].freeze

  def channel_css_class(channel)
    case channel.to_s.downcase
    when /linkedin/ then "badge-linkedin"
    when /instagram/ then "badge-instagram"
    when /email/ then "badge-email"
    when /twitter/, /\bx\b/ then "badge-twitter"
    when /tiktok/ then "badge-tiktok"
    when /facebook/ then "badge-facebook"
    when /blog/ then "badge-blog"
    when /forum/, /reddit/ then "badge-forum"
    when /slack/, /discord/ then "badge-community"
    else "badge-default"
    end
  end

  def campaign_color_class(campaign_id, campaign_ids)
    index = campaign_ids.index(campaign_id) || 0
    CAMPAIGN_COLORS[index % CAMPAIGN_COLORS.size]
  end
end
