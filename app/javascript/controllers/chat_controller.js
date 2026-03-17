import { Controller } from "@hotwired/stimulus"
import { marked } from "marked"

export default class extends Controller {
  static targets = ["messages", "submit", "loading", "fileInput", "filePreview", "fileName", "textarea"]

  connect() {
    this.renderMarkdown()
    this.scrollToBottom()
  }

  autoResize(event) {
    const textarea = event.target
    textarea.style.height = "auto"
    textarea.style.height = textarea.scrollHeight + "px"
  }

  submitOnEnter(event) {
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault()
      event.target.closest("form").requestSubmit()
    }
  }

  renderMarkdown() {
    this.messagesTarget.querySelectorAll(".bubble-bot").forEach(el => {
      el.innerHTML = marked.parse(el.textContent.trim())
    })
  }

  scrollToBottom() {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }

  submit() {
    this.submitTarget.disabled = true
    this.loadingTarget.classList.remove("d-none")
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
