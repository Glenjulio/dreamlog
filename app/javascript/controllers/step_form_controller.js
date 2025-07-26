import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["step", "previous", "next", "submit"]
  static values = { current: Number }

  connect() {
    if (this.currentValue === undefined) {
      this.currentValue = 0
    }
    this.updateStepVisibility()
  }

  next() {
    if (this.currentValue < this.stepTargets.length - 1) {
      this.currentValue++
      this.updateStepVisibility()
    }
  }

  previous() {
    if (this.currentValue > 0) {
      this.currentValue--
      this.updateStepVisibility()
    }
  }

  updateStepVisibility() {
    this.stepTargets.forEach((element, index) => {
      element.classList.toggle("d-none", index !== this.currentValue)
    })

    if (this.hasPreviousTarget) {
      this.previousTarget.classList.toggle("d-none", this.currentValue === 0)
    }

    if (this.hasNextTarget) {
      this.nextTarget?.classList.toggle("d-none", this.currentValue === this.stepTargets.length - 1)
    }

    if (this.hasSubmitTarget) {
      this.submitTarget?.classList.toggle("d-none", this.currentValue !== this.stepTargets.length - 1)
    }
  }
}
