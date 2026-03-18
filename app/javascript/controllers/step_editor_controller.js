function buildChannelMeta(name) {
  const handle = `@${name.toLowerCase().replace(/\s+/g, "_")}`
  return {
    "LinkedIn":        { color: "#0A66C2", sub: `${name} · Maintenant · 🌐`,  actions: ["👍 J'aime", "💬 Commenter", "↗ Partager"] },
    "Twitter / X":     { color: "#000000", sub: handle,                         actions: ["💬 0", "🔁 0", "❤️ 0", "↗"] },
    "Email":           { color: "#6366f1", sub: "À : votre liste",              actions: ["📤 Envoyer"] },
    "Instagram":       { color: "#E1306C", sub: handle,                         actions: ["❤️ 0", "💬 0", "↗"] },
    "TikTok":          { color: "#010101", sub: handle,                         actions: ["❤️ 0", "💬 0", "🔁 0"] },
    "Facebook":        { color: "#1877F2", sub: `${name} · Public`,             actions: ["👍 J'aime", "💬 Commenter", "↗ Partager"] },
    "Blog / Article":  { color: "#7c3aed", sub: `${name} · Blog`,               actions: ["📖 Lire", "💬 Commenter"] },
    "Forum / Reddit":  { color: "#FF4500", sub: `u/${name.toLowerCase()}`,       actions: ["⬆️ 0", "💬 0", "↗ Partager"] },
    "Slack / Discord": { color: "#4A154B", sub: "#marketing",                   actions: ["😊", "💬 Répondre", "↗"] },
    "Autre":           { color: "#6b7280", sub: name,                            actions: ["↗ Partager"] },
  }
}

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "statusBadge", "statusSelect",
    "channelSelect",
    "contentArea", "contentBody", "charCount",
    "previewText", "previewSub", "previewAvatar", "previewAccent",
    "previewActions", "previewChannelName",
  ]
  static values = { channelLimits: Object, userName: String, userInitial: String }

  connect() {
    this.channelMeta = buildChannelMeta(this.userNameValue || "Vous")
    this.updateCharCount()
    this.updatePreview()
    this._applyChannelMeta(this._selectedChannel())

    // Active toolbar state on selection change
    this._selectionHandler = () => this._updateToolbarState()
    document.addEventListener("selectionchange", this._selectionHandler)
  }

  disconnect() {
    document.removeEventListener("selectionchange", this._selectionHandler)
  }

  _updateToolbarState() {
    const cmdMap = { bold: "bold", italic: "italic", strike: "strikeThrough" }
    this.element.querySelectorAll("[data-step-editor-fmt-param]").forEach(btn => {
      const fmt = btn.dataset.stepEditorFmtParam
      const cmd = cmdMap[fmt]
      if (cmd) btn.classList.toggle("is-active", document.queryCommandState(cmd))
    })
  }

  // Keyboard shortcuts: Ctrl+B, Ctrl+I
  keyFormat(event) {
    const ctrl = event.ctrlKey || event.metaKey
    if (!ctrl) return
    const map = { b: "bold", i: "italic" }
    const fmt = map[event.key.toLowerCase()]
    if (!fmt) return
    event.preventDefault()
    this._execFmt(fmt)
  }

  // Toolbar buttons (mousedown keeps contenteditable focus + selection)
  format(event) {
    event.preventDefault()
    this._execFmt(event.params.fmt)
  }

  _execFmt(fmt) {
    const cmdMap = {
      bold:   ["bold",               null],
      italic: ["italic",             null],
      strike: ["strikeThrough",      null],
      ul:     ["insertUnorderedList", null],
      ol:     ["insertOrderedList",  null],
    }
    const [cmd] = cmdMap[fmt] || []
    if (!cmd) return
    this.contentAreaTarget.focus()
    document.execCommand(cmd, false, null)
    this._syncContent()
    this.onInput()
  }

  _syncContent() {
    if (this.hasContentBodyTarget)
      this.contentBodyTarget.value = this.contentAreaTarget.innerHTML
  }

  // Called on contenteditable input
  onInput() {
    this._syncContent()
    this.updateCharCount()
    this.updatePreview()
  }

  // Called on channel radio change
  updateChannelUI() {
    const channel = this._selectedChannel()
    this._applyChannelMeta(channel)
    this.updateCharCount()
    this.updatePreview()
  }

  updateStatusBadge() {
    const val = this.statusSelectTarget.value
    const labels = { pending: "En attente", done: "Fait" }
    this.statusBadgeTarget.className = `step-status-pill ${val}`
    this.statusBadgeTarget.innerHTML =
      `<span class="step-status-dot"></span>${labels[val] || val}`
  }

  // Char count
  updateCharCount() {
    if (!this.hasContentAreaTarget || !this.hasCharCountTarget) return

    const count  = (this.contentAreaTarget.textContent || "").length
    const limit  = this.channelLimitsValue[this._selectedChannel()] || 0

    if (limit > 0) {
      const remaining = limit - count
      const over      = remaining < 0
      this.charCountTarget.textContent = over
        ? `${Math.abs(remaining)} de trop`
        : `${remaining} restants`
      this.charCountTarget.className =
        `step-char-count ${over ? "over" : remaining < limit * 0.1 ? "warning" : ""}`
    } else {
      const cnt = (this.contentAreaTarget.textContent || "").length
      this.charCountTarget.textContent = cnt > 0 ? `${cnt} car.` : ""
      this.charCountTarget.className = "step-char-count"
    }
  }

  // Live preview — mirrors contenteditable HTML directly
  updatePreview() {
    if (!this.hasPreviewTextTarget || !this.hasContentAreaTarget) return
    const html = this.contentAreaTarget.innerHTML || ""
    const isEmpty = !this.contentAreaTarget.textContent.trim()
    if (isEmpty) {
      this.previewTextTarget.textContent = "Votre contenu apparaîtra ici…"
      this.previewTextTarget.classList.add("is-placeholder")
    } else {
      this.previewTextTarget.innerHTML = html
      this.previewTextTarget.classList.remove("is-placeholder")
    }
  }

  // Apply channel color + sub + actions to preview
  _applyChannelMeta(channel) {
    const meta = this.channelMeta[channel] || this.channelMeta["Autre"]

    if (this.hasPreviewAccentTarget)
      this.previewAccentTarget.style.background = meta.color

    if (this.hasPreviewAvatarTarget)
      this.previewAvatarTarget.style.background = meta.color

    if (this.hasPreviewSubTarget)
      this.previewSubTarget.textContent = meta.sub

    if (this.hasPreviewActionsTarget)
      this.previewActionsTarget.innerHTML =
        meta.actions.map(a => `<span>${a}</span>`).join("")

    if (this.hasPreviewChannelNameTarget)
      this.previewChannelNameTarget.textContent = channel
  }

  _selectedChannel() {
    if (!this.hasChannelSelectTarget) return "Autre"
    const checked = this.channelSelectTarget.querySelector("input[type=radio]:checked")
    return checked ? checked.value : "Autre"
  }
}
