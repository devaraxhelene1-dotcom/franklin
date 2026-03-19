import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.onScroll = this.onScroll.bind(this)
    window.addEventListener("scroll", this.onScroll, { passive: true })
    this.onScroll()
  }

  disconnect() {
    window.removeEventListener("scroll", this.onScroll)
  }

  onScroll() {
    this.element.classList.toggle("scrolled", window.scrollY > 20)
  }
}
