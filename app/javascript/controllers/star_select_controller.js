import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["star", "input"]

  connect() {
    this.selected = 0
  }

  rate(event) {
    const value = parseInt(event.currentTarget.dataset.value, 10)
    this.selected = value

    this.starTargets.forEach(star => {
      const starValue = parseInt(star.dataset.value, 10)
      star.classList.toggle("selected", starValue <= value)
    })

    if (this.hasInputTarget) {
      this.inputTarget.value = value
    }
  }
}
