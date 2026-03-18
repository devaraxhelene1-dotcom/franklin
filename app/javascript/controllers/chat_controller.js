import { Controller } from "@hotwired/stimulus"
import { marked } from "marked"

export default class extends Controller {
  static targets = ["messages", "submit", "loading", "validationLoading", "fileInput", "filePreview", "fileName", "content", "typewriterBlack", "typewriterGreen"]

  connect() {
    this.renderMarkdown()
    this.updateLayout()
    this.scrollToBottom()

    // Lancer l'effet typewriter
    this.typeWriterDual()

    // Observer les nouveaux messages ajoutés par Turbo Stream
    this.observer = new MutationObserver(() => {
      this.renderMarkdown()
      this.updateLayout()
      this.scrollToBottom()

      // Afficher le loading seulement après que le message user est apparu dans le chat
      if (this._waitingForMessage) {
        this._waitingForMessage = false
        this.loadingTarget.classList.remove("d-none")
        this.scrollToBottom()
      }
    })
    this.observer.observe(this.messagesTarget, { childList: true })
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
  }

  typeWriterDual() {
    const blackText = "Discutez avec "
    const greenText = "Franklin"
    let index = 0

    const typeBlack = () => {
      if (index < blackText.length) {
        this.typewriterBlackTarget.textContent += blackText.charAt(index)
        index++
        setTimeout(typeBlack, 80)
      } else {
        index = 0
        setTimeout(typeGreen, 80)
      }
    }

    const typeGreen = () => {
      if (index < greenText.length) {
        this.typewriterGreenTarget.textContent += greenText.charAt(index)
        index++
        setTimeout(typeGreen, 80)
      } else {
        // Animation terminée, cacher le curseur
        const title = this.typewriterBlackTarget.closest('.chat-title')
        if (title) title.classList.add('typewriter-finished')
      }
    }

    typeBlack()
  }

  autoResize(event) {
    const textarea = event.target
    const maxHeight = 200
    textarea.style.height = "auto"
    const newHeight = Math.min(textarea.scrollHeight, maxHeight)
    textarea.style.height = newHeight + "px"
    textarea.style.overflowY = textarea.scrollHeight > maxHeight ? "auto" : "hidden"
  }

  submitOnEnter(event) {
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault()
      event.target.closest("form").requestSubmit()
    }
  }

  renderMarkdown() {
    this.messagesTarget.querySelectorAll(".bubble-bot").forEach(el => {
      // Éviter de re-parser un élément déjà converti
      if (el.dataset.rendered) return
      el.innerHTML = marked.parse(el.textContent.trim())
      el.dataset.rendered = "true"
    })
  }

  scrollToBottom() {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }

  updateLayout() {
    const messagesContainer = this.messagesTarget
    // Compter les messages (en excluant le loading indicator)
    const messageCount = messagesContainer.querySelectorAll(".message:not(#loading-indicator)").length
    const hasMessages = messageCount > 0

    // Ajouter ou retirer la classe has-messages
    this.element.classList.toggle("has-messages", hasMessages)
  }

  submit() {
    this.submitTarget.disabled = true
    this._waitingForMessage = true
  }

  submitValidation() {
    this.validationLoadingTarget.classList.remove("d-none")
  }

  fileChange() {
    const file = this.fileInputTarget.files[0]
    if (file) {
      this.fileNameTarget.textContent = file.name
      this.filePreviewTarget.classList.remove("d-none")
    }
  }

  removeFile() {
    this.fileInputTarget.value = ""
    this.filePreviewTarget.classList.add("d-none")
    this.fileNameTarget.textContent = ""
  }
}
