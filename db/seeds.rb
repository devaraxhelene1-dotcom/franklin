# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Nettoyage de la base de données..."
Message.destroy_all
Chat.destroy_all
Step.destroy_all
Campaign.destroy_all
User.destroy_all

# ============================================================
# UTILISATEURS
# ============================================================
puts "Création des utilisateurs..."

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
# CAMPAGNES
# ============================================================
puts "Création des campagnes..."

campaign1 = Campaign.create!(
  title: "Outbound SaaS - Fondateurs de startups",
  icp: "Fondateurs de startups (Seed - Série A)",
  status: "active",
  angles: "Gagner du temps grâce à l'automatisation, augmenter la productivité de l'équipe",
  channels: "LinkedIn, Email",
  doc_content: "Campagne conçue pour générer des rendez-vous avec des fondateurs de startups via une plateforme SaaS de productivité.",
  user: helene
)

campaign2 = Campaign.create!(
  title: "Outil Marketing IA",
  icp: "Responsables Marketing dans des entreprises SaaS",
  status: "draft",
  angles: "Automatisation marketing par IA, meilleur ROI",
  channels: "Email",
  doc_content: "Campagne d'emailing à froid pour promouvoir un outil IA à destination des équipes marketing.",
  user: zoe
)

campaign3 = Campaign.create!(
  title: "Lancement DevTool - CTOs & Tech Leads",
  icp: "CTOs et Tech Leads dans des scale-ups (50-500 employés)",
  status: "completed",
  angles: "Réduire la dette technique, livrer plus vite avec de meilleurs outils",
  channels: "LinkedIn, Email, Twitter",
  doc_content: "Campagne outbound multi-canal ciblant les décideurs techniques pour un outil de productivité développeur. Focus sur les problèmes de CI/CD, les goulots d'étranglement en revue de code et l'expérience développeur.",
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
  title: "Plateforme Analytics E-commerce",
  icp: "Responsables e-commerce & Growth leads dans des marques DTC",
  status: "draft",
  angles: "Tableau de bord analytics unifié, clarté sur l'attribution, augmentation du ROAS",
  channels: "Email",
  doc_content: "Prospection ciblant les décideurs e-commerce confrontés à des problèmes d'attribution multi-canal et de données éparpillées.",
  user: zoe
)

# ============================================================
# ÉTAPES
# ============================================================
puts "Création des étapes..."

# -------- Campagne 1 (active) --------
Step.create!(
  campaign: campaign1,
  day: 1,
  status: "done",
  generated_content: "Demande de connexion LinkedIn :\n\nBonjour Hélène, j'accompagne des fondateurs de startups pour automatiser leurs tâches répétitives et gagner des heures chaque semaine. Connectons-nous !"
)

Step.create!(
  campaign: campaign1,
  day: 2,
  status: "done",
  generated_content: "Relance LinkedIn :\n\nMerci pour la connexion Hélène ! Une question rapide — comment gérez-vous actuellement l'automatisation des workflows internes dans votre équipe ?"
)

Step.create!(
  campaign: campaign1,
  day: 4,
  status: "pending",
  generated_content: "Message LinkedIn :\n\nNous avons récemment aidé une startup à réduire ses tâches manuelles de 40 %. Je peux vous expliquer comment si vous êtes curieux."
)

Step.create!(
  campaign: campaign1,
  day: 6,
  status: "pending",
  generated_content: "Relance email :\n\nObjet : Une idée rapide pour votre entreprise\n\nBonjour Hélène,\n\nJe ne sais pas si l'automatisation des workflows est une priorité en ce moment, mais nous avons récemment aidé une équipe similaire à votre entreprise à gagner plus de 10 heures par semaine.\n\nÇa vaut le coup d'y jeter un œil ?"
)

# -------- Campagne 2 (brouillon) --------
Step.create!(
  campaign: campaign2,
  day: 1,
  status: "pending",
  generated_content: "Email à froid :\n\nObjet : IA pour l'équipe marketing de votre entreprise\n\nBonjour Zoé,\n\nNous avons développé un assistant IA qui aide les équipes marketing à générer des campagnes, du contenu et des messages de prospection plus rapidement.\n\nSeriez-vous disponible pour une démo rapide de 10 min ?"
)

Step.create!(
  campaign: campaign2,
  day: 3,
  status: "pending",
  generated_content: "Relance email :\n\nBonjour Zoé,\n\nJe reviens rapidement pour savoir si cela pourrait être utile pour votre équipe.\n\nCertaines entreprises voient leurs campagnes créées 3 fois plus vite grâce à l'IA.\n\nJe serais ravi de vous montrer."
)

Step.create!(
  campaign: campaign2,
  day: 7,
  status: "pending",
  generated_content: "Dernière relance :\n\nBonjour Zoé,\n\nSi ce n'est pas une priorité pour l'instant, pas de souci — souhaitez-vous que je revienne vers vous dans quelques mois ?"
)

# -------- Campagne 3 (terminée) --------
Step.create!(
  campaign: campaign3,
  day: 1,
  status: "done",
  generated_content: "Demande de connexion LinkedIn :\n\nBonjour Hélène, j'ai remarqué que votre entreprise évolue rapidement — nous aidons les équipes tech à livrer 2 fois plus vite en supprimant les goulots d'étranglement CI/CD. Connectons-nous !"
)

Step.create!(
  campaign: campaign3,
  day: 3,
  status: "done",
  generated_content: "Message LinkedIn :\n\nMerci pour la connexion ! Je suis curieux — quel est le plus grand point de friction pour votre équipe dev en ce moment ? Nous échangeons avec beaucoup de CTOs qui souffrent de cycles de revue de code trop lents."
)

Step.create!(
  campaign: campaign3,
  day: 5,
  status: "done",
  generated_content: "Email :\n\nObjet : Productivité des développeurs dans votre entreprise\n\nBonjour Hélène,\n\nNous avons aidé une équipe d'ingénierie de 200 personnes à réduire leur temps de déploiement de 45 min à 8 min.\n\nCela vaut-il un appel de 15 min pour voir si on peut faire pareil dans votre entreprise ?"
)

Step.create!(
  campaign: campaign3,
  day: 7,
  status: "done",
  generated_content: "DM Twitter :\n\nSalut Hélène — j'ai vu votre tweet sur l'expérience développeur. On construit quelque chose dans cet espace. J'aimerais avoir votre avis si vous avez 10 min."
)

Step.create!(
  campaign: campaign3,
  day: 10,
  status: "done",
  generated_content: "Email final :\n\nObjet : Mon dernier message !\n\nBonjour Hélène,\n\nJe sais que votre boîte mail est chargée, donc je fais court — si les outils dev sont un jour sur la feuille de route, je serais ravi d'être une ressource.\n\nSans pression, je suis là si vous avez besoin."
)

# -------- Campagne 4 (active) --------
Step.create!(
  campaign: campaign4,
  day: 1,
  status: "done",
  generated_content: "Demande de connexion LinkedIn :\n\nBonjour Marc, je travaille avec des agences digitales qui cherchent à staffeur leurs projets plus rapidement avec des freelances tech qualifiés. Connectons-nous !"
)

Step.create!(
  campaign: campaign4,
  day: 3,
  status: "pending",
  generated_content: "Message LinkedIn :\n\nMerci pour la connexion Marc ! Comment gérez-vous actuellement le recrutement de freelances dans votre entreprise ? On aide des agences comme la vôtre à diviser par 2 le temps de staffing."
)

Step.create!(
  campaign: campaign4,
  day: 5,
  status: "pending",
  generated_content: "Email :\n\nObjet : Staffing tech pour votre entreprise\n\nBonjour Marc,\n\nNous avons aidé une agence de 30 personnes à réduire leur time-to-hire de 3 semaines à 5 jours.\n\nÇa vaut le coup d'en discuter 15 min ?"
)

# -------- Campagne 5 (brouillon) --------
Step.create!(
  campaign: campaign5,
  day: 1,
  status: "pending",
  generated_content: "Email à froid :\n\nObjet : Les analytics de votre entreprise, enfin unifiés\n\nBonjour Zoé,\n\nVous suivez vos performances sur Shopify, Meta, Google et Klaviyo dans des tableaux de bord séparés ? Nous regroupons tout en une seule vue avec une attribution claire.\n\nVous souhaitez voir comment ça fonctionne en 10 min ?"
)

Step.create!(
  campaign: campaign5,
  day: 4,
  status: "pending",
  generated_content: "Relance email :\n\nBonjour Zoé,\n\nJuste un petit rappel — nos clients DTC constatent une amélioration de 20 à 30 % de leur ROAS simplement en corrigeant leur modèle d'attribution.\n\nJe serais ravi de vous montrer ce que nous avons observé pour des marques comme votre entreprise."
)

# ============================================================
# CHATS
# ============================================================
puts "Création des chats..."

chat1 = Chat.create!(title: "Stratégie outbound SaaS", user: helene, campaign: campaign1)
chat2 = Chat.create!(title: "Mise en place campagne LinkedIn", user: helene, campaign: campaign1)
chat3 = Chat.create!(title: "Séquence d'emails à froid", user: zoe, campaign: campaign2)
chat4 = Chat.create!(title: "Bilan campagne DevTool", user: helene, campaign: campaign3)
chat5 = Chat.create!(title: "Stratégie agences digitales", user: marc, campaign: campaign4)
chat6 = Chat.create!(title: "Conseils outbound généraux", user: marc, campaign: campaign4)

# ============================================================
# MESSAGES
# ============================================================
puts "Création des messages..."

# -------- Chat 1 --------
Message.create!(chat: chat1, role: "user", content: "Je veux cibler des fondateurs de startups avec un outil SaaS d'automatisation.")
Message.create!(chat: chat1, role: "assistant", content: "Super ! Construisons une campagne outbound multi-étapes via LinkedIn et email. Je recommande de commencer par une demande de connexion LinkedIn, suivie d'une relance axée sur la valeur, puis de passer à l'email pour les dernières touches.")
Message.create!(chat: chat1, role: "user", content: "Peux-tu générer la demande de connexion LinkedIn ?")
Message.create!(chat: chat1, role: "assistant", content: "Voici une suggestion :\n\n« Bonjour {{first_name}}, j'accompagne des fondateurs de startups pour automatiser leurs tâches répétitives et gagner des heures chaque semaine. Connectons-nous ! »\n\nGardez-le court et orienté curiosité. Pas de pitch dans le premier message.")

# -------- Chat 2 --------
Message.create!(chat: chat2, role: "user", content: "À quoi doit ressembler mon premier message LinkedIn ?")
Message.create!(chat: chat2, role: "assistant", content: "Faites court et personnalisé. Cherchez d'abord à créer le lien plutôt qu'à pitcher. Mentionnez quelque chose de spécifique sur leur profil ou leur entreprise pour vous démarquer.")

# -------- Chat 3 --------
Message.create!(chat: chat3, role: "user", content: "Peux-tu générer un email à froid pour un outil marketing IA ?")
Message.create!(chat: chat3, role: "assistant", content: "Bien sûr. On va commencer par un email court axé sur le ROI et les gains de productivité. Voici un brouillon :\n\nObjet : IA pour l'équipe marketing de {{company}}\n\nBonjour {{first_name}},\n\nNous avons développé un assistant IA qui aide les équipes marketing à générer des campagnes, du contenu et des messages de prospection plus rapidement.\n\nSeriez-vous disponible pour une démo rapide de 10 min ?")
Message.create!(chat: chat3, role: "user", content: "Peux-tu ajouter une relance pour le jour 3 ?")
Message.create!(chat: chat3, role: "assistant", content: "Voici une relance plus douce :\n\nBonjour {{first_name}},\n\nJe reviens rapidement pour savoir si cela pourrait être utile pour votre équipe. Certaines entreprises voient leurs campagnes créées 3 fois plus vite grâce à l'IA.\n\nJe serais ravi de vous montrer.")

# -------- Chat 4 --------
Message.create!(chat: chat4, role: "user", content: "La campagne DevTool est terminée. Qu'est-ce qui a le mieux fonctionné ?")
Message.create!(chat: chat4, role: "assistant", content: "D'après les résultats de la campagne, la demande de connexion LinkedIn a eu le taux d'acceptation le plus élevé (35 %). L'email du jour 5 a généré le plus de réponses. Le DM Twitter était une bonne idée mais avec moins de volume. Je recommande de miser davantage sur LinkedIn + email pour la prochaine itération.")

# -------- Chat 5 --------
Message.create!(chat: chat5, role: "user", content: "Je veux cibler les dirigeants d'agences digitales pour une plateforme de freelances.")
Message.create!(chat: chat5, role: "assistant", content: "Bonne cible ! Je recommande une approche LinkedIn d'abord, puis email. Les dirigeants d'agences sont très actifs sur LinkedIn. On va structurer une séquence en 3 étapes sur 5 jours.")
Message.create!(chat: chat5, role: "user", content: "Quels angles utiliser ?")
Message.create!(chat: chat5, role: "assistant", content: "Deux angles principaux :\n1. **Time-to-hire** : réduire le temps de staffing de semaines à jours\n2. **Qualité** : accéder à un pool de freelances déjà vérifiés et qualifiés\n\nLe premier angle fonctionne mieux en accroche, le second en relance.")

# -------- Chat 6 --------
Message.create!(chat: chat6, role: "user", content: "Quel est le nombre idéal d'étapes dans une séquence outbound ?")
Message.create!(chat: chat6, role: "assistant", content: "Pour l'outbound B2B, 4 à 7 points de contact sur 2 à 3 semaines est la bonne fourchette. Trop peu et vous ratez des personnes occupées. Trop et vous risquez de les agacer. Mélangez les canaux (LinkedIn + email) pour de meilleurs résultats.")

puts "Seed terminé ! ✅"
puts "Créé : #{User.count} utilisateurs, #{Campaign.count} campagnes, #{Step.count} étapes, #{Chat.count} chats, #{Message.count} messages"
