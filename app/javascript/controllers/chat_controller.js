import { Controller } from "@hotwired/stimulus"
import { marked } from "marked"

export default class extends Controller {
  static targets = ["messages", "submit", "loading", "validationLoading", "fileInput", "filePreview", "fileName", "content"]

  connect() {
    this.renderMarkdown()
    this.scrollToBottom()

    // Observer les nouveaux messages ajoutés par Turbo Stream
    this.observer = new MutationObserver(() => {
      this.renderMarkdown()
      this.scrollToBottom()
    })
    this.observer.observe(this.messagesTarget, { childList: true })
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
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

  submit() {
    this.submitTarget.disabled = true
    this.loadingTarget.classList.remove("d-none")
    this.scrollToBottom()
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
