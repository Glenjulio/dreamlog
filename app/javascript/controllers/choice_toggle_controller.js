// app/javascript/controllers/choice_toggle_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]

  connect() {
    this.buttonTargets.forEach((el) => {
      if (el.querySelector("input:checked")) {
        el.classList.add("active")
      }
    })
  }

  toggle(event) {
    this.buttonTargets.forEach((el) => el.classList.remove("active"))
    event.currentTarget.classList.add("active")
  }
}
