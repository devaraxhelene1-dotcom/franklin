


import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel"]

  toggle() {
    this.panelTarget.classList.toggle("collapsed")
    document.body.classList.toggle("sidebar-collapsed")
  }
}
