// app/javascript/flash_notifications.js
document.addEventListener('DOMContentLoaded', function() {
  // Handle Rails flash messages
  const flashData = document.querySelector('script[data-notifications]')
  if (flashData) {
    try {
      const notifications = JSON.parse(flashData.textContent)

      // Wait for Stimulus to be loaded
      setTimeout(() => {
        notifications.forEach(notification => {
          showNotification(notification.message, notification.type)
        })
      }, 100)

      // Remove the script tag after processing
      flashData.remove()
    } catch (e) {
      console.error('Error parsing flash notifications:', e)
    }
  }
})

// Global function to show notifications
window.showNotification = function(message, type = 'info', duration = 5000) {
  const container = document.querySelector('[data-notifications-target="container"]')
  if (!container) {
    console.warn('Notifications container not found')
    return
  }

  const event = new CustomEvent('show-notification', {
    detail: { message, type, duration }
  })

  container.dispatchEvent(event)
}

// Handle custom notification events
document.addEventListener('show-notification', function(event) {
  const container = event.target
  const { message, type, duration } = event.detail

  const controller = window.Stimulus?.getControllerForElementAndIdentifier(container, 'notifications')

  if (controller) {
    controller.messageValue = message
    controller.typeValue = type
    controller.durationValue = duration
    controller.show()
  }
})

// Enhanced notification functions with English messages
window.notifications = {
  success: (message) => showNotification(message, 'success'),
  error: (message) => showNotification(message, 'error'),
  warning: (message) => showNotification(message, 'warning'),
  info: (message) => showNotification(message, 'info'),

  // Predefined messages in English
  dreamSaved: () => showNotification('Dream saved successfully!', 'success'),
  dreamDeleted: () => showNotification('Dream deleted successfully!', 'success'),
  transcriptionCompleted: () => showNotification('Transcription completed!', 'success'),
  analysisGenerated: () => showNotification('Dream analysis generated!', 'success'),
  recordingSaved: () => showNotification('Recording saved successfully!', 'success'),
  recordingDeleted: () => showNotification('Recording deleted!', 'info'),
  profileUpdated: () => showNotification('Profile updated successfully!', 'success'),

  // Error messages
  accessDenied: () => showNotification('Access denied. Please sign in.', 'error'),
  unexpectedError: () => showNotification('An unexpected error occurred. Please try again.', 'error'),
  networkError: () => showNotification('Network error. Please check your connection.', 'error'),
  microphoneError: () => showNotification('Microphone access denied. Please allow microphone access.', 'error'),

  // Warning messages
  unsavedChanges: () => showNotification('You have unsaved changes!', 'warning'),
  longProcessing: () => showNotification('This may take a few moments...', 'warning')
}
