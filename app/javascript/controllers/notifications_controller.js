// app/javascript/controllers/notifications_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]
  static values = {
    message: String,
    type: String,
    duration: { type: Number, default: 5000 }
  }

  connect() {
    if (this.hasMessageValue && this.messageValue) {
      this.show()
    }
  }

  show() {
    // Create notification element
    const notification = this.createNotification()

    // Add to container
    this.containerTarget.appendChild(notification)

    // Animate in
    requestAnimationFrame(() => {
      notification.classList.add('show')
    })

    // Auto hide after duration
    if (this.durationValue > 0) {
      setTimeout(() => {
        this.hide(notification)
      }, this.durationValue)
    }
  }

  createNotification() {
    const notification = document.createElement('div')
    notification.className = `notification notification-${this.typeValue}`

    const icon = this.getIcon(this.typeValue)

    notification.innerHTML = `
      <div class="notification-content">
        <div class="notification-icon">
          <i class="fas ${icon}"></i>
        </div>
        <div class="notification-message">
          ${this.messageValue}
        </div>
        <button class="notification-close" data-action="click->notifications#hideNotification">
          <i class="fas fa-times"></i>
        </button>
      </div>
    `

    return notification
  }

  getIcon(type) {
    switch(type) {
      case 'success': return 'fa-check-circle'
      case 'error': return 'fa-exclamation-circle'
      case 'warning': return 'fa-exclamation-triangle'
      case 'info': return 'fa-info-circle'
      default: return 'fa-bell'
    }
  }

  hideNotification(event) {
    const notification = event.target.closest('.notification')
    this.hide(notification)
  }

  hide(notification) {
    notification.classList.add('hide')

    setTimeout(() => {
      if (notification.parentNode) {
        notification.parentNode.removeChild(notification)
      }
    }, 300)
  }

  // Static method to show notifications from anywhere
  static show(message, type = 'info', duration = 5000) {
    const container = document.querySelector('[data-notifications-target="container"]')
    if (!container) return

    const controller = window.Stimulus.getControllerForElementAndIdentifier(container, 'notifications')
    if (controller) {
      controller.messageValue = message
      controller.typeValue = type
      controller.durationValue = duration
      controller.show()
    }
  }
}
