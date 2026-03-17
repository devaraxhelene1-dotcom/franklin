import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "grid"]

  filter() {
    const id = this.selectTarget.value
    this.gridTarget.querySelectorAll(".calendar-badge").forEach(badge => {
      badge.style.display = (id === "all" || badge.dataset.campaignId === id) ? "" : "none"
    })
  }
}
