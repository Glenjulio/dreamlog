import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["option"]

  connect() {
    this.selected = null
  }

  select(event) {
    this.optionTargets.forEach(btn => btn.classList.remove("selected"))
    event.currentTarget.classList.add("selected")
    this.selected = event.currentTarget.dataset.value

    const input = this.element.querySelector("input[name='transcription[tag]']")
    if (input) input.value = this.selected
  }
}
