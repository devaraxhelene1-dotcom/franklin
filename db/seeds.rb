# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Cleaning database..."
Message.destroy_all
Chat.destroy_all
Step.destroy_all
Campaign.destroy_all
User.destroy_all

# ============================================================
# USERS
# ============================================================
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

marc = User.create!(
  email: "marc@gmail.com",
  password: "123456",
  username: "marc"
)

# ============================================================
# CAMPAIGNS
# ============================================================
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

campaign3 = Campaign.create!(
  title: "DevTool Launch - CTOs & Tech Leads",
  icp: "CTOs and Tech Leads in scale-ups (50-500 employees)",
  status: "completed",
  angles: "Reduce technical debt, ship faster with better tooling",
  channels: "LinkedIn, Email, Twitter",
  doc_content: "Multi-channel outbound campaign targeting technical decision-makers for a developer productivity tool. Focus on pain points around CI/CD, code review bottlenecks, and developer experience.",
  user: helene
)

campaign4 = Campaign.create!(
  title: "Recrutement - Agences Digitales",
  icp: "Dirigeants d'agences digitales (10-50 personnes)",
  status: "active",
  angles: "Accéder aux meilleurs freelances tech, réduire le time-to-hire",
  channels: "LinkedIn, Email",
  doc_content: "Campagne outbound pour une plateforme de mise en relation entre agences digitales et freelances qualifiés.",
  user: marc
)

campaign5 = Campaign.create!(
  title: "E-commerce Analytics Platform",
  icp: "E-commerce managers & Growth leads in DTC brands",
  status: "draft",
  angles: "Unified analytics dashboard, attribution clarity, increase ROAS",
  channels: "Email",
  doc_content: "Cold outreach targeting e-commerce decision-makers struggling with multi-channel attribution and scattered data.",
  user: zoe
)

# ============================================================
# STEPS
# ============================================================
puts "Creating steps..."

# -------- Campaign 1 (active) --------
Step.create!(
  campaign: campaign1,
  day: 1,
  status: "done",
  generated_content: "LinkedIn connection request:\n\nHi {{first_name}}, I work with startup founders helping them automate repetitive workflows and save hours every week. Would love to connect!"
)

Step.create!(
  campaign: campaign1,
  day: 2,
  status: "done",
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

# -------- Campaign 2 (draft) --------
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

# -------- Campaign 3 (completed) --------
Step.create!(
  campaign: campaign3,
  day: 1,
  status: "done",
  generated_content: "LinkedIn connection request:\n\nHi {{first_name}}, I noticed {{company}} is scaling fast — we help tech teams ship 2x faster by eliminating CI/CD bottlenecks. Would love to connect!"
)

Step.create!(
  campaign: campaign3,
  day: 3,
  status: "done",
  generated_content: "LinkedIn message:\n\nThanks for connecting! I'm curious — what's the biggest pain point for your dev team right now? We've been talking to a lot of CTOs dealing with slow code review cycles."
)

Step.create!(
  campaign: campaign3,
  day: 5,
  status: "done",
  generated_content: "Email:\n\nSubject: Developer productivity at {{company}}\n\nHi {{first_name}},\n\nWe helped a 200-person engineering team cut their deployment time from 45 min to 8 min.\n\nWorth a 15-min call to see if we can do the same for {{company}}?"
)

Step.create!(
  campaign: campaign3,
  day: 7,
  status: "done",
  generated_content: "Twitter DM:\n\nHey {{first_name}} — saw your tweet about developer experience. We're building something in that space. Would love your take on it if you have 10 min."
)

Step.create!(
  campaign: campaign3,
  day: 10,
  status: "done",
  generated_content: "Final email:\n\nSubject: Last one from me!\n\nHi {{first_name}},\n\nI know your inbox is busy so I'll keep this short — if dev tooling is ever on the roadmap, I'd love to be a resource.\n\nNo pressure, just here if you need us."
)

# -------- Campaign 4 (active) --------
Step.create!(
  campaign: campaign4,
  day: 1,
  status: "done",
  generated_content: "Demande de connexion LinkedIn:\n\nBonjour {{first_name}}, je travaille avec des agences digitales qui cherchent à staffeur leurs projets plus rapidement avec des freelances tech qualifiés. Connectons-nous !"
)

Step.create!(
  campaign: campaign4,
  day: 3,
  status: "pending",
  generated_content: "Message LinkedIn:\n\nMerci pour la connexion {{first_name}} ! Comment gérez-vous actuellement le recrutement de freelances chez {{company}} ? On aide des agences comme la vôtre à diviser par 2 le temps de staffing."
)

Step.create!(
  campaign: campaign4,
  day: 5,
  status: "pending",
  generated_content: "Email:\n\nObjet: Staffing tech pour {{company}}\n\nBonjour {{first_name}},\n\nNous avons aidé une agence de 30 personnes à réduire leur time-to-hire de 3 semaines à 5 jours.\n\nÇa vaut le coup d'en discuter 15 min ?"
)

# -------- Campaign 5 (draft) --------
Step.create!(
  campaign: campaign5,
  day: 1,
  status: "pending",
  generated_content: "Cold Email:\n\nSubject: Your {{company}} analytics, unified\n\nHi {{first_name}},\n\nTracking performance across Shopify, Meta, Google, and Klaviyo in separate dashboards? We bring it all into one view with clear attribution.\n\nWant to see how it works in 10 min?"
)

Step.create!(
  campaign: campaign5,
  day: 4,
  status: "pending",
  generated_content: "Follow-up email:\n\nHi {{first_name}},\n\nJust a quick bump — our DTC clients are seeing 20-30% better ROAS just from fixing their attribution model.\n\nHappy to show you what we found for brands like {{company}}."
)

# ============================================================
# CHATS
# ============================================================
puts "Creating chats..."

chat1 = Chat.create!(title: "SaaS outbound strategy", user: helene, campaign: campaign1)
chat2 = Chat.create!(title: "LinkedIn campaign setup", user: helene, campaign: campaign1)
chat3 = Chat.create!(title: "Cold email sequence", user: zoe, campaign: campaign2)
chat4 = Chat.create!(title: "DevTool campaign debrief", user: helene, campaign: campaign3)
chat5 = Chat.create!(title: "Stratégie agences digitales", user: marc, campaign: campaign4)
chat6 = Chat.create!(title: "General outbound tips", user: marc, campaign: campaign4)

# ============================================================
# MESSAGES
# ============================================================
puts "Creating messages..."

# -------- Chat 1 --------
Message.create!(chat: chat1, role: "user", content: "I want to target startup founders with a SaaS automation tool.")
Message.create!(chat: chat1, role: "assistant", content: "Great! Let's build a multi-step outbound campaign using LinkedIn and email. I recommend starting with a LinkedIn connection request, followed by a value-driven follow-up, then transitioning to email for the final touches.")
Message.create!(chat: chat1, role: "user", content: "Can you generate the LinkedIn connection request?")
Message.create!(chat: chat1, role: "assistant", content: "Here's a suggestion:\n\n\"Hi {{first_name}}, I work with startup founders helping them automate repetitive workflows and save hours every week. Would love to connect!\"\n\nKeep it short and curiosity-driven. No pitch in the first message.")

# -------- Chat 2 --------
Message.create!(chat: chat2, role: "user", content: "What should my LinkedIn first message look like?")
Message.create!(chat: chat2, role: "assistant", content: "Keep it short and personalized. Focus on connecting first rather than pitching. Mention something specific about their profile or company to stand out.")

# -------- Chat 3 --------
Message.create!(chat: chat3, role: "user", content: "Can you generate a cold email for a marketing AI tool?")
Message.create!(chat: chat3, role: "assistant", content: "Sure. We'll start with a short email focused on ROI and productivity gains. Here's a draft:\n\nSubject: AI for {{company}} marketing team\n\nHi {{first_name}},\n\nWe built an AI assistant that helps marketing teams generate campaigns, content and outreach faster.\n\nWould you be open to a quick 10-min demo?")
Message.create!(chat: chat3, role: "user", content: "Can you add a follow-up for day 3?")
Message.create!(chat: chat3, role: "assistant", content: "Here's a softer follow-up:\n\nHi {{first_name}},\n\nJust checking if this could be relevant for your team. Some companies are seeing 3x faster campaign creation with AI.\n\nHappy to show you.")

# -------- Chat 4 --------
Message.create!(chat: chat4, role: "user", content: "The DevTool campaign is done. What worked best?")
Message.create!(chat: chat4, role: "assistant", content: "Based on the campaign results, the LinkedIn connection request had the highest acceptance rate (35%). The email on day 5 drove the most replies. The Twitter DM was a nice touch but lower volume. I'd recommend doubling down on LinkedIn + email for the next iteration.")

# -------- Chat 5 --------
Message.create!(chat: chat5, role: "user", content: "Je veux cibler les dirigeants d'agences digitales pour une plateforme de freelances.")
Message.create!(chat: chat5, role: "assistant", content: "Bonne cible ! Je recommande une approche LinkedIn d'abord, puis email. Les dirigeants d'agences sont très actifs sur LinkedIn. On va structurer une séquence en 3 étapes sur 5 jours.")
Message.create!(chat: chat5, role: "user", content: "Quels angles utiliser ?")
Message.create!(chat: chat5, role: "assistant", content: "Deux angles principaux :\n1. **Time-to-hire** : réduire le temps de staffing de semaines à jours\n2. **Qualité** : accéder à un pool de freelances déjà vérifiés et qualifiés\n\nLe premier angle fonctionne mieux en accroche, le second en relance.")

# -------- Chat 6 --------
Message.create!(chat: chat6, role: "user", content: "What's the ideal number of steps in an outbound sequence?")
Message.create!(chat: chat6, role: "assistant", content: "For B2B outbound, 4-7 touchpoints over 2-3 weeks is the sweet spot. Too few and you miss people who are busy. Too many and you risk annoying them. Mix channels (LinkedIn + email) for better results.")

puts "Finished seeding database! ✅"
puts "Created: #{User.count} users, #{Campaign.count} campaigns, #{Step.count} steps, #{Chat.count} chats, #{Message.count} messages"
