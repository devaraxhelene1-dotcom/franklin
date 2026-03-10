# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
puts "Cleaning database..."
Message.destroy_all
Chat.destroy_all
Step.destroy_all
Campaign.destroy_all
User.destroy_all

puts "Creating users..."

helene = User.create!(
  email: "helene@gmail.com",
  password: "1234567",
  username: "helene"
)

zoe = User.create!(
  email: "zoe@gmail.com",
  password: "123456",
  username: "zoe"
)

puts "Creating chats..."

chat1 = Chat.create!(title: "SaaS outbound strategy", user: helene)
chat2 = Chat.create!(title: "LinkedIn campaign setup", user: helene)
chat3 = Chat.create!(title: "Cold email sequence", user: zoe)

puts "Creating campaigns..."

campaign1 = Campaign.create!(
  title: "Outbound SaaS - Startup Founders",
  icp: "Startup founders (Seed - Series A)",
  status: "active",
  angles: "Save time with automation, increase team productivity",
  channels: "LinkedIn, Email",
  doc_content: "Campaign designed to generate meetings with startup founders using a SaaS productivity platform.",
  user: helene
)

campaign2 = Campaign.create!(
  title: "AI Marketing Tool",
  icp: "Head of Marketing in SaaS companies",
  status: "draft",
  angles: "AI-powered marketing automation, better ROI",
  channels: "Email",
  doc_content: "Cold email campaign promoting an AI tool for marketing teams.",
  user: zoe
)

puts "Creating steps..."

# -------- Campaign 1 --------

Step.create!(
  campaign: campaign1,
  day: 1,
  status: "pending",
  generated_content: "LinkedIn connection request:\n\nHi {{first_name}}, I work with startup founders helping them automate repetitive workflows and save hours every week. Would love to connect!"
)

Step.create!(
  campaign: campaign1,
  day: 2,
  status: "pending",
  generated_content: "LinkedIn follow-up:\n\nThanks for connecting {{first_name}}! Quick question — how are you currently handling internal workflow automation in your team?"
)

Step.create!(
  campaign: campaign1,
  day: 4,
  status: "pending",
  generated_content: "LinkedIn message:\n\nWe recently helped a startup reduce manual ops work by 40%. Happy to share how if you're curious."
)

Step.create!(
  campaign: campaign1,
  day: 6,
  status: "pending",
  generated_content: "Email follow-up:\n\nSubject: Quick idea for {{company}}\n\nHi {{first_name}},\n\nNot sure if workflow automation is a priority right now, but we recently helped a team similar to {{company}} save 10+ hours per week.\n\nWorth a quick look?"
)

# -------- Campaign 2 --------

Step.create!(
  campaign: campaign2,
  day: 1,
  status: "pending",
  generated_content: "Cold Email:\n\nSubject: AI for {{company}} marketing team\n\nHi {{first_name}},\n\nWe built an AI assistant that helps marketing teams generate campaigns, content and outreach faster.\n\nWould you be open to a quick 10-min demo?"
)

Step.create!(
  campaign: campaign2,
  day: 3,
  status: "pending",
  generated_content: "Follow-up email:\n\nHi {{first_name}},\n\nJust checking if this could be relevant for your team.\n\nSome companies are seeing 3x faster campaign creation with AI.\n\nHappy to show you."
)

Step.create!(
  campaign: campaign2,
  day: 7,
  status: "pending",
  generated_content: "Last follow-up:\n\nHi {{first_name}},\n\nIf this isn't a priority right now no worries — should I circle back in a few months?"
)

puts "Creating messages..."

Message.create!(
  chat: chat1,
  role: "user",
  content: "I want to target startup founders with a SaaS automation tool."
)

Message.create!(
  chat: chat1,
  role: "assistant",
  content: "Great! Let's build a multi-step outbound campaign using LinkedIn and email."
)

Message.create!(
  chat: chat2,
  role: "user",
  content: "What should my LinkedIn first message look like?"
)

Message.create!(
  chat: chat2,
  role: "assistant",
  content: "Keep it short and personalized. Focus on connecting first rather than pitching."
)

Message.create!(
  chat: chat3,
  role: "user",
  content: "Can you generate a cold email for a marketing AI tool?"
)

Message.create!(
  chat: chat3,
  role: "assistant",
  content: "Sure. We'll start with a short email focused on ROI and productivity gains."
)

puts "Finished seeding database 🚀"
