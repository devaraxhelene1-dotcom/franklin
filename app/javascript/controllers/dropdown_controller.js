import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "chevron"]

  toggle(event) {
    event.preventDefault()
    if (this.hasMenuTarget) {
      this.menuTarget.toggleAttribute("hidden")
    }
    if (this.hasChevronTarget) {
      this.chevronTarget.classList.toggle("rotated")
    }
  }
}
