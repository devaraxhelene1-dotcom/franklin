import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "instructions", "charCount", "previewBody", "previewFooter", "previewChannel", "channelMeta", "previewCard"]

  connect() {
    this.updatePreview()
  }

  updatePreview() {
    const content = this.hasContentTarget ? this.contentTarget.value : ""
    const channel = this.selectedChannel()

    if (this.hasCharCountTarget) {
      this.charCountTarget.textContent = `${content.length} car.`
    }

    if (this.hasPreviewBodyTarget) {
      this.previewBodyTarget.textContent = content.slice(0, 240) || "Votre contenu apparaîtra ici…"
    }

    if (this.hasPreviewChannelTarget) {
      this.previewChannelTarget.textContent = channel
    }

    if (this.hasPreviewFooterTarget) {
      this.previewFooterTarget.style.display = channel ? "block" : "none"
    }

    if (this.hasChannelMetaTarget) {
      const meta = this.buildChannelMeta(channel)
      if (meta) {
        this.channelMetaTarget.textContent = meta
        this.channelMetaTarget.classList.add("visible")
      } else {
        this.channelMetaTarget.textContent = ""
        this.channelMetaTarget.classList.remove("visible")
      }
    }
  }

  selectedChannel() {
    const checked = this.element.querySelector("input[name='step[channel]']:checked")
    return checked ? checked.value : ""
  }

  buildChannelMeta(name) {
    const limits = {
      "Twitter":   "Limite : 280 caractères",
      "LinkedIn":  "Idéal : 150–300 mots · Hashtags : 3–5",
      "Instagram": "Légende : max 2 200 car. · Hashtags : jusqu'à 30",
      "TikTok":    "Légende courte · Trending sounds · Hashtags : 3–5",
      "Email":     "Objet accrocheur · CTA clair · Longueur : 150–300 mots",
      "SMS":       "Limite : 160 caractères · Lien court conseillé",
      "Blog":      "SEO optimisé · H1 unique · 800–2 000 mots recommandés",
    }
    return limits[name] || null
  }
}
