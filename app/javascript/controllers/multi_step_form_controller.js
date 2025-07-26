// app/javascript/controllers/multi_step_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["step", "previous", "next", "submit"]
  static values = { current: Number }

  connect() {
    this.currentValue = 0
    this.updateSteps()
  }

  nextStep() {
    if (this.currentValue < this.stepTargets.length - 1) {
      this.currentValue++
      this.updateSteps()
    }
  }

  prevStep() {
    if (this.currentValue > 0) {
      this.currentValue--
      this.updateSteps()
    }
  }

  updateSteps() {
    this.stepTargets.forEach((el, index) => {
      el.classList.toggle("d-none", index !== this.currentValue)
    })

    // Affichage conditionnel des boutons
    if (this.hasPreviousTarget) {
      this.previousTarget.classList.toggle("d-none", this.currentValue === 0)
    }

    if (this.hasNextTarget) {
      this.nextTarget.classList.toggle("d-none", this.currentValue === this.stepTargets.length - 1)
    }

    if (this.hasSubmitTarget) {
      this.submitTarget.classList.toggle("d-none", this.currentValue !== this.stepTargets.length - 1)
    }
  }
}
