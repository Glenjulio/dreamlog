// app/javascript/controllers/form_steps_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["step", "submit"]

  connect() {
    this.currentStep = 0
    this.showStep(this.currentStep)
  }

  showStep(index) {
    this.stepTargets.forEach((el, i) => {
      el.classList.toggle("active", i === index)
    })

    if (this.hasSubmitTarget) {
      this.submitTarget.classList.toggle("d-none", index !== this.stepTargets.length - 1)
    }
  }

  next() {
    if (this.currentStep < this.stepTargets.length - 1) {
      this.currentStep++
      this.showStep(this.currentStep)
    }
  }

  prev() {
    if (this.currentStep > 0) {
      this.currentStep--
      this.showStep(this.currentStep)
    }
  }
}
