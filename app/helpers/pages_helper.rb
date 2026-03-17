module PagesHelper
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
end
