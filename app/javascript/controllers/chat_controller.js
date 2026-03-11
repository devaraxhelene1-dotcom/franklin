import { Controller } from "@hotwired/stimulus"
import { marked } from "marked"

export default class extends Controller {
  static targets = ["messages", "submit", "loading"]

  connect() {
    this.renderMarkdown()
    this.scrollToBottom()
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
}
