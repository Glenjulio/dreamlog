// app/javascript/controllers/chat_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea", "form"]

  connect() {
    console.log("Chat form controller connected")
  }

  // Gère l'appui sur les touches
  handleKeydown(event) {
    // Si Enter est pressé SANS Shift
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault() // Empêche le saut de ligne
      this.submitForm()
    }
    // Si Shift + Enter, laisse le comportement par défaut (saut de ligne)
  }

  // Soumet le formulaire
  submitForm() {
    const content = this.textareaTarget.value.trim()

    // N'envoie pas si le message est vide
    if (content.length === 0) {
      return
    }

    // Soumet le formulaire
    this.formTarget.requestSubmit()
  }
}
