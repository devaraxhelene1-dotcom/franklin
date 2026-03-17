import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["statusSelect", "statusPill"]
  static values  = { statusLabels: Object }

  updatePill() {
    const val = this.statusSelectTarget.value
    const label = this.statusLabelsValue[val] || val
    this.statusPillTarget.className = `campaign-status-pill ${val}`
    this.statusPillTarget.textContent = label
  }
}
