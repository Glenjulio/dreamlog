// app/javascript/controllers/emoji_select_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["emoji"]

  connect() {
    this.selected = null
  }

  select(event) {
    this.emojiTargets.forEach(el => el.classList.remove("selected"))
    event.currentTarget.classList.add("selected")
    this.selected = event.currentTarget.dataset.value

    const hiddenInput = this.element.querySelector("input[name='transcription[mood]']")
    if (hiddenInput) {
      hiddenInput.value = this.selected
    }
  }
}
