// app/javascript/controllers/analysis_loader_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "title", "message", "encouragement"]

  connect() {
    this.messageIndex = 0
    this.titleIndex = 0
    this.encouragementIndex = 0
    this.messageInterval = null
    this.titleInterval = null
    this.encouragementInterval = null
  }

  disconnect() {
    this.stopAllIntervals()
  }

  // Messages qui changent pendant l'analyse
  messages = [
    "Interpreting symbols and emotions...",
    "Analyzing dream patterns...",
    "Connecting subconscious elements...",
    "Exploring psychological meanings...",
    "Unveiling hidden insights...",
    "Processing emotional layers...",
    "Decoding symbolic representations...",
    "Mapping unconscious thoughts..."
  ]

  // Titres qui changent
  titles = [
    "Analyzing your dream...",
    "Diving into your subconscious...",
    "Exploring your inner world...",
    "Deciphering your night journey..."
  ]

  // Messages d'encouragement
  encouragements = [
    "This may take a few moments...",
    "Great insights are coming...",
    "Your dream is being carefully analyzed...",
    "Almost ready with your analysis...",
    "Preparing something special for you..."
  ]

  // Méthode pour afficher le loader
  show() {
    // Afficher l'overlay
    this.overlayTarget.classList.add("show")

    // Empêcher le scroll du body
    document.body.style.overflow = 'hidden'

    // Démarrer les animations des textes
    this.startTextAnimations()

    console.log("🔮 Analysis loader shown")
  }

  // Méthode pour cacher le loader
  hide() {
    // Cacher l'overlay
    this.overlayTarget.classList.remove("show")

    // Restaurer le scroll du body
    document.body.style.overflow = ''

    // Arrêter les animations
    this.stopAllIntervals()

    console.log("✨ Analysis loader hidden")
  }

  // Démarrer toutes les animations de texte
  startTextAnimations() {
    // Changer les messages toutes les 3 secondes
    this.messageInterval = setInterval(() => {
      this.cycleMessage()
    }, 3000)

    // Changer les titres toutes les 8 secondes
    this.titleInterval = setInterval(() => {
      this.cycleTitle()
    }, 8000)

    // Changer les encouragements toutes les 6 secondes
    this.encouragementInterval = setInterval(() => {
      this.cycleEncouragement()
    }, 6000)
  }

  // Arrêter toutes les animations
  stopAllIntervals() {
    if (this.messageInterval) {
      clearInterval(this.messageInterval)
      this.messageInterval = null
    }
    if (this.titleInterval) {
      clearInterval(this.titleInterval)
      this.titleInterval = null
    }
    if (this.encouragementInterval) {
      clearInterval(this.encouragementInterval)
      this.encouragementInterval = null
    }
  }

  // Changer le message principal
  cycleMessage() {
    if (!this.hasMessageTarget) return

    this.messageIndex = (this.messageIndex + 1) % this.messages.length

    // Animation de fondu
    this.messageTarget.style.opacity = '0'

    setTimeout(() => {
      this.messageTarget.textContent = this.messages[this.messageIndex]
      this.messageTarget.style.opacity = '1'
    }, 200)
  }

  // Changer le titre
  cycleTitle() {
    if (!this.hasTitleTarget) return

    this.titleIndex = (this.titleIndex + 1) % this.titles.length

    // Animation de fondu
    this.titleTarget.style.opacity = '0'

    setTimeout(() => {
      this.titleTarget.textContent = this.titles[this.titleIndex]
      this.titleTarget.style.opacity = '1'
    }, 300)
  }

  // Changer le message d'encouragement
  cycleEncouragement() {
    if (!this.hasEncouragementTarget) return

    this.encouragementIndex = (this.encouragementIndex + 1) % this.encouragements.length

    // Animation de fondu
    this.encouragementTarget.style.opacity = '0'

    setTimeout(() => {
      this.encouragementTarget.textContent = this.encouragements[this.encouragementIndex]
      this.encouragementTarget.style.opacity = '1'
    }, 250)
  }

  // Méthode statique pour utiliser le loader depuis n'importe où
  static show() {
    const loader = document.querySelector('[data-controller*="analysis-loader"]')
    if (loader) {
      const controller = window.Stimulus.getControllerForElementAndIdentifier(loader, 'analysis-loader')
      if (controller) {
        controller.show()
      }
    }
  }

  static hide() {
    const loader = document.querySelector('[data-controller*="analysis-loader"]')
    if (loader) {
      const controller = window.Stimulus.getControllerForElementAndIdentifier(loader, 'analysis-loader')
      if (controller) {
        controller.hide()
      }
    }
  }
}
