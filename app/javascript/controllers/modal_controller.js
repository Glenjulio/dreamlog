// app/javascript/controllers/modal_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["backdrop", "dialog", "input", "confirmButton", "cancelButton"]
  static values = {
    title: String,
    placeholder: String,
    confirmText: String,
    cancelText: String
  }

  connect() {
    this.resolveCallback = null
    this.rejectCallback = null
    this.isVisible = false
  }

  // Méthode principale pour afficher le modal et retourner une Promise
  show(options = {}) {
    return new Promise((resolve, reject) => {
      this.resolveCallback = resolve
      this.rejectCallback = reject

      // Configurer les options
      this.titleValue = options.title || "Enter title"
      this.placeholderValue = options.placeholder || ""
      this.confirmTextValue = options.confirmText || "Save"
      this.cancelTextValue = options.cancelText || "Cancel"

      // Mettre à jour l'UI
      this.updateUI()
      this.showModal()
    })
  }

  updateUI() {
    // Mettre à jour le placeholder de l'input
    if (this.hasInputTarget) {
      this.inputTarget.placeholder = this.placeholderValue
      this.inputTarget.value = ""
    }

    // Mettre à jour les textes des boutons
    if (this.hasConfirmButtonTarget) {
      this.confirmButtonTarget.textContent = this.confirmTextValue
    }

    if (this.hasCancelButtonTarget) {
      this.cancelButtonTarget.textContent = this.cancelTextValue
    }
  }

  showModal() {
    this.isVisible = true
    this.element.classList.remove('d-none')

    // Force un reflow avant d'ajouter la classe 'show'
    this.element.offsetHeight

    this.element.classList.add('show')

    // Focus sur l'input après l'animation
    setTimeout(() => {
      if (this.hasInputTarget) {
        this.inputTarget.focus()
      }
    }, 300)

    // Empêcher le scroll du body
    document.body.style.overflow = 'hidden'
  }

  hideModal() {
    this.isVisible = false
    this.element.classList.remove('show')

    setTimeout(() => {
      this.element.classList.add('d-none')
      document.body.style.overflow = ''
    }, 300)
  }

  // Action pour le bouton de confirmation
  confirm() {
    const value = this.inputTarget.value.trim()

    if (!value) {
      // Ajouter une classe d'erreur pour feedback visuel
      this.inputTarget.classList.add('is-invalid')
      this.inputTarget.focus()
      return
    }

    this.inputTarget.classList.remove('is-invalid')
    this.hideModal()

    if (this.resolveCallback) {
      this.resolveCallback(value)
    }
  }

  // Action pour le bouton d'annulation
  cancel() {
    this.hideModal()

    if (this.rejectCallback) {
      this.rejectCallback(new Error('User cancelled'))
    }
  }

  // Capturer tous les clics dans la modal
// Copier le comportement du bouton Save
  debugFocus(event) {
    // Si ce n'est pas un bouton, faire comme le bouton Save
    if (!event.target.matches('button') && this.hasInputTarget) {
      // Exactement comme dans confirm() quand l'input est vide
      this.inputTarget.classList.remove('is-invalid')
      this.inputTarget.focus()
    }
  }

  // Action pour cliquer sur le backdrop
  backdropClick(event) {
    // Plus précis : vérifier que c'est VRAIMENT le backdrop et pas un élément enfant
    if (event.target === this.backdropTarget && !event.target.closest('[data-modal-target="dialog"]')) {
      // this.cancel() // Toujours commenté
    }
  }

  // Gestion des touches clavier
  keydown(event) {
    if (!this.isVisible) return

    if (event.key === 'Enter') {
      event.preventDefault()
      this.confirm()
    } else if (event.key === 'Escape') {
      event.preventDefault()
      this.cancel()
    }
  }

  // Nettoyer les callbacks lors de la déconnexion
  disconnect() {
    document.body.style.overflow = ''
    this.resolveCallback = null
    this.rejectCallback = null
  }
}
