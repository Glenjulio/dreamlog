// app/javascript/controllers/analysis_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "submitButton"]

  connect() {
    console.log("Analysis form controller connected")
  }

  // Méthode appelée quand on clique sur le bouton "Analyse"
  submitWithLoader(event) {
    // Empêcher la soumission immédiate du formulaire
    event.preventDefault()

    console.log("🔮 Starting analysis with loader...")

    // Afficher le loader
    this.showLoader()

    // Attendre un petit délai pour que le loader s'affiche
    setTimeout(() => {
      // Puis soumettre le formulaire
      this.submitForm()
    }, 300)
  }

  showLoader() {
    const loader = document.querySelector('[data-controller*="analysis-loader"]')
    if (loader) {
      const controller = window.Stimulus.getControllerForElementAndIdentifier(loader, 'analysis-loader')
      if (controller) {
        controller.show()
        console.log("✨ Loader shown")
      }
    }
  }

  submitForm() {
    // Soumettre le formulaire de manière normale
    if (this.hasFormTarget) {
      console.log("📤 Submitting form...")
      this.formTarget.submit()
    }
  }

  // Méthode alternative : soumettre directement avec fetch pour plus de contrôle
  async submitWithFetch(event) {
    event.preventDefault()

    this.showLoader()

    try {
      const formData = new FormData(this.formTarget)
      const response = await fetch(this.formTarget.action, {
        method: 'POST',
        body: formData,
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        }
      })

      if (response.redirected) {
        // Suivre la redirection
        window.location.href = response.url
      } else {
        // Gérer les erreurs
        console.error('Form submission error')
        this.hideLoader()
      }
    } catch (error) {
      console.error('Network error:', error)
      this.hideLoader()
    }
  }

  hideLoader() {
    const loader = document.querySelector('[data-controller*="analysis-loader"]')
    if (loader) {
      const controller = window.Stimulus.getControllerForElementAndIdentifier(loader, 'analysis-loader')
      if (controller) {
        controller.hide()
      }
    }
  }
}
