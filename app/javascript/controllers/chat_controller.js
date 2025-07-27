import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chat"
export default class extends Controller {
  static targets = ["button", "panel"]
  static classes = ["active"]

  connect() {
    console.log("Chat controller connected")
    this.isOpen = false
  }

  toggle(event) {
    event.preventDefault()

    if (this.isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    console.log("Opening chat...")
    this.isOpen = true

    // Ajouter la classe active au bouton
    if (this.hasButtonTarget) {
      this.buttonTarget.classList.add("active")
    }

    // Notification temporaire
    this.showTemporaryNotification("Chat bot sera bientôt disponible!")
  }

  close() {
    console.log("Closing chat...")
    this.isOpen = false

    // Retirer la classe active du bouton
    if (this.hasButtonTarget) {
      this.buttonTarget.classList.remove("active")
    }
  }

  // Méthode temporaire pour montrer une notification
  showTemporaryNotification(message) {
    // Utilise le système de notification existant de l'app si disponible
    if (window.showNotification) {
      window.showNotification(message, 'info')
    } else {
      // Fallback avec alert simple
      alert(message)
    }
  }
}
