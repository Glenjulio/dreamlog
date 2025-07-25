import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"

export default class extends Controller {
  static targets = ["button", "deleteButton", "saveButton", "timer"]

  connect() {
    this.recording = false
    this.mediaRecorder = null
    this.audioChunks = []
    this.audioBlob = null
    this.audioUrl = null
    this.audioElement = null
    this.isPlaying = false
    this.timerInterval = null
    this.elapsedSeconds = 0
  }

  toggle() {
    // Si on est en train d’écouter → revenir au mode enregistrement
    if (!this.recording && this.audioElement && !this.isPlaying) {
      this.resetToRecordingButton()
      return
    }

    this.recording = !this.recording

    if (this.recording) {
      this.startRecording()
    } else {
      this.stopRecording()
    }
  }

  resetToRecordingButton() {
    this.buttonTarget.innerHTML = '<i class="fa-solid fa-microphone-lines fa-2x"></i>'
    this.buttonTarget.title = "Start recording"
    this.buttonTarget.dataset.action = "click->recordings#toggle"
  }

  startTimer() {
    this.elapsedSeconds = 0
    this.updateTimerDisplay()
    this.timerInterval = setInterval(() => {
      this.elapsedSeconds += 1
      this.updateTimerDisplay()
    }, 1000)
  }

  stopTimer() {
    clearInterval(this.timerInterval)
    this.timerInterval = null
  }

  updateTimerDisplay() {
    const minutes = String(Math.floor(this.elapsedSeconds / 60)).padStart(2, "0")
    const seconds = String(this.elapsedSeconds % 60).padStart(2, "0")
    this.timerTarget.textContent = `${minutes}:${seconds}`
  }

  startRecording() {
    navigator.mediaDevices.getUserMedia({ audio: true })
      .then(stream => {
        this.audioChunks = []
        this.mediaRecorder = new MediaRecorder(stream)

        this.mediaRecorder.ondataavailable = event => {
          if (event.data.size > 0) {
            this.audioChunks.push(event.data)
          }
        }

        this.mediaRecorder.onstop = () => {
          this.audioBlob = new Blob(this.audioChunks, { type: "audio/webm" })
          this.audioUrl = URL.createObjectURL(this.audioBlob)
          this.setupAudioElement()
          this.showDecisionButtons()
          this.stopTimer()
          console.log("Timer stopped after recording")
        }

        this.buttonTarget.innerHTML = '<i class="fa-solid fa-stop fa-2x"></i>'
        this.mediaRecorder.start()
        this.startTimer()
        if (this.hasTimerTarget) {
          this.timerTarget.classList.remove("d-none")
        }
        console.log("Recording started")
      })
      .catch(error => {
        console.error("Microphone access error:", error)
        this.recording = false
        this.buttonTarget.textContent = "Record"
        this.hideAllButtons()
        this.showErrorMessage(error)
      })
  }

  stopRecording() {
    if (this.mediaRecorder && this.mediaRecorder.state !== "inactive") {
      this.mediaRecorder.stop()
      this.buttonTarget.innerHTML = '<i class="fas fa-play fa-2x"></i>'
      this.buttonTarget.title = "Listen to your recording"
      this.buttonTarget.dataset.action = "click->recordings#togglePlayback"
    }
  }

  setupAudioElement() {
    if (this.audioUrl) {
      this.audioElement = new Audio(this.audioUrl)
      this.audioElement.addEventListener('ended', () => {
        this.isPlaying = false
        this.updatePlayIcon()
      })
    }
  }

  togglePlayback() {
    if (!this.audioElement) return

    if (this.isPlaying) {
      this.audioElement.pause()
      this.isPlaying = false
    } else {
      this.audioElement.play()
      this.isPlaying = true
    }
    this.updatePlayIcon()
  }

  updatePlayIcon() {
    const icon = this.isPlaying ? 'fa-pause' : 'fa-play'
    this.buttonTarget.innerHTML = `<i class="fas ${icon} fa-2x"></i>`
  }

  showDecisionButtons() {
    if (this.hasDeleteButtonTarget) {
      this.deleteButtonTarget.classList.remove("d-none")
    }

    if (this.hasSaveButtonTarget) {
      this.saveButtonTarget.classList.remove("d-none")
    }
  }

  hideAllButtons() {
    if (this.hasDeleteButtonTarget) {
      this.deleteButtonTarget.classList.add("d-none")
    }

    if (this.hasSaveButtonTarget) {
      this.saveButtonTarget.classList.add("d-none")
    }
  }

  saveAndTranscribe() {
    const title = window.prompt("Give a title to your dream:")
    if (!title?.trim()) {
      this.showCustomNotification("A title is required to save your dream!", "warning")
      return
    }

    console.log("Starting save process...")
    this.showLoadingState("Saving in progress...")

    const file = new File([this.audioBlob], "recording.webm", {
      type: "audio/webm"
    })

    const upload = new DirectUpload(file, "/rails/active_storage/direct_uploads")

    upload.create((error, blob) => {
      if (error) {
        console.error("Direct upload failed:", error)
        this.hideLoadingState()
        this.showCustomNotification("Error during uploading. Try again.", "error")
        return
      }

      const dreamData = {
        dream: {
          title: title,
          tags: "voice_recording",
          private: false,
          audio: blob.signed_id
        }
      }

      fetch("/dreams.json", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-CSRF-Token": this.getMetaValue("csrf-token")
        },
        body: JSON.stringify(dreamData)
      })
      .then(response => {
        if (!response.ok) {
          throw new Error(`HTTP ${response.status}: ${response.statusText}`)
        }
        return response.json()
      })
      .then(data => {
        this.hideLoadingState()

        if (data.success) {
          const dreamId = data.id
          this.showCustomNotification("Dream saved, transcribing...", "info")

          fetch(`/dreams/${dreamId}/transcribe`, {
            method: "POST",
            headers: {
              "X-CSRF-Token": this.getMetaValue("csrf-token")
            }
          })
          .then(resp => {
            if (resp.redirected) {
              window.location.href = resp.url
            } else {
              this.showCustomNotification("Transcription failed or not redirected", "warning")
              window.location.href = `/dreams/${dreamId}`
            }
          })
          .catch(error => {
            console.error("Transcription failed:", error)
            this.showCustomNotification("Error during transcription", "error")
            window.location.href = `/dreams/${dreamId}`
          })
        } else {
          throw new Error(data.errors?.join(", ") || "Unknown error")
        }
      })
      .catch(error => {
        console.error("Error during save:", error)
        this.hideLoadingState()
        this.showCustomNotification(`Failed to save dream: ${error.message}` , "error")
      })
    })
  }

  discardRecording() {
    this.cleanupRecording()
    this.showCustomNotification("Recording deleted!", "info")
  }

  cleanupRecording() {
    if (this.audioUrl) {
      URL.revokeObjectURL(this.audioUrl)
    }

    this.audioBlob = null
    this.audioUrl = null
    this.audioElement = null
    this.isPlaying = false
    this.updateTimerDisplay()

    this.hideAllButtons()
    this.resetToRecordingButton()
  }

  showLoadingState(message) {
    const loader = document.createElement('div')
    loader.className = 'loading-overlay'
    loader.innerHTML = `
      <div class="spinner-border text-light" role="status">
        <span class="visually-hidden">Loading...</span>
      </div>
      <p class="mt-3 text-white">${message}</p>
    `
    loader.style.cssText = `
      position: fixed;
      top: 0; left: 0; right: 0; bottom: 0;
      background: rgba(26, 0, 51, 0.9);
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      z-index: 9999;
      backdrop-filter: blur(5px);
    `
    document.body.appendChild(loader)
  }

  hideLoadingState() {
    const loader = document.querySelector('.loading-overlay')
    if (loader) loader.remove()
  }

  showErrorMessage(error) {
    let message = "An error occurred"

    if (error.name === "NotAllowedError") {
      message = "Microphone access refused. Please allow it in your browser"
    } else if (error.name === "NotFoundError") {
      message = "No microphone found on your device"
    }

    this.showCustomNotification(message, "error")
  }

  showCustomNotification(message, type) {
    const container = document.querySelector('[data-notifications-target="container"]')
    if (!container) return

    const notification = document.createElement('div')
    notification.className = `notification notification-${type}`

    const icon = this.getNotificationIcon(type)

    notification.innerHTML = `
      <div class="notification-content">
        <div class="notification-icon">
          <i class="fas ${icon}"></i>
        </div>
        <div class="notification-message">
          ${message}
        </div>
        <button class="notification-close" onclick="this.parentNode.parentNode.remove()">
          <i class="fas fa-times"></i>
        </button>
      </div>
    `

    container.appendChild(notification)
    setTimeout(() => notification.classList.add('show'), 10)
    setTimeout(() => notification.remove(), 5000)
  }

  getNotificationIcon(type) {
    switch(type) {
      case 'success': return 'fa-check-circle'
      case 'error': return 'fa-exclamation-circle'
      case 'warning': return 'fa-exclamation-triangle'
      case 'info': return 'fa-info-circle'
      default: return 'fa-bell'
    }
  }

  getMetaValue(name) {
    const element = document.head.querySelector(`meta[name="${name}"]`)
    return element?.getAttribute("content")
  }
}
