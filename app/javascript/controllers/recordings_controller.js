import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"

export default class extends Controller {
  static targets = ["button", "playButton", "decisionButtons", "timer"]

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
    this.recording = !this.recording

    if (this.recording) {
      this.startRecording()
    } else {
      this.stopRecording()
    }
  }

  // fonctions chrono
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

        // MONTRER le bouton Play immédiatement (mais désactivé)
        this.showPlayButtonDisabled()

        this.mediaRecorder.ondataavailable = event => {
          if (event.data.size > 0) {
            this.audioChunks.push(event.data)
          }
        }

        this.mediaRecorder.onstop = () => {
          this.audioBlob = new Blob(this.audioChunks, { type: "audio/webm" })
          this.audioUrl = URL.createObjectURL(this.audioBlob)
          this.setupAudioElement()
          // ACTIVER le bouton Play ET montrer les boutons de décision
          this.enablePlayButton()
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
      this.buttonTarget.innerHTML = '<i class="fa-solid fa-microphone-lines fa-2x"></i>'
    }
  }

  setupAudioElement() {
    if (this.audioUrl) {
      this.audioElement = new Audio(this.audioUrl)
      this.audioElement.addEventListener('ended', () => {
        this.isPlaying = false
        this.updatePlayButton()
      })
    }
  }

  // Montrer le bouton Play mais désactivé (pendant enregistrement)
  showPlayButtonDisabled() {
    this.playButtonTarget.classList.remove("d-none")
    this.playButtonTarget.disabled = true
    this.playButtonTarget.classList.add("disabled")
    this.playButtonTarget.innerHTML = '<i class="fas fa-play"></i>'
    this.playButtonTarget.title = "<<<<Recording in progress>>>>"
  }

  // Activer le bouton Play (après enregistrement)
  enablePlayButton() {
    this.playButtonTarget.disabled = false
    this.playButtonTarget.classList.remove("disabled")
    this.playButtonTarget.title = "Listen to recording"
    this.updatePlayButton()
  }

  // Montrer les boutons de décision
  showDecisionButtons() {
    this.decisionButtonsTarget.classList.remove("d-none")
  }

  // Cacher tous les boutons
  hideAllButtons() {
    this.playButtonTarget.classList.add("d-none")
    this.decisionButtonsTarget.classList.add("d-none")
    this.playButtonTarget.disabled = false
    this.playButtonTarget.classList.remove("disabled")
  }

  togglePlayback() {
    // Ne rien faire si désactivé
    if (this.playButtonTarget.disabled) return
    if (!this.audioElement) return

    if (this.isPlaying) {
      this.audioElement.pause()
      this.isPlaying = false
    } else {
      this.audioElement.play()
      this.isPlaying = true
    }
    this.updatePlayButton()
  }

  updatePlayButton() {
    const icon = this.isPlaying ? 'fa-pause' : 'fa-play'
    this.playButtonTarget.innerHTML = `<i class="fas ${icon}"></i>`
  }

  // FONCTION DIRECTE : Sauvegarder (appelée par le bouton)
saveAndTranscribe() {
  const title = prompt("Give a title to your dream")
  if (!title?.trim()) {
    alert("A title is required to save your dream")
    return
  }

  console.log("Starting save process...")

  // Afficher état de chargement
  this.showLoadingState("Saving in progress...")

  const file = new File([this.audioBlob], "recording.webm", {
    type: "audio/webm"
  })

  console.log("File created:", file)

  const upload = new DirectUpload(file, "/rails/active_storage/direct_uploads")

  upload.create((error, blob) => {
    if (error) {
      console.error("Direct upload failed:", error)
      this.hideLoadingState()
      alert("Error during uploading. Try again.")
      return
    }

    console.log("Direct upload successful:", blob)
    console.log("Now creating dream...")

    // DÉFINIR dreamData D'ABORD
    const dreamData = {
      dream: {
        title: title,
        tags: "voice_recording",
        private: false,
        audio: blob.signed_id
        // Removed: auto_transcribe: true
      }
    }

    console.log("Sending dream data:", dreamData)

    // PUIS faire le fetch avec .json
    fetch("/dreams.json", {  // ← .json ajouté
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": this.getMetaValue("csrf-token")
      },
      body: JSON.stringify(dreamData)
    })
    .then(response => {
      console.log("Response status:", response.status)
      console.log("Response headers:", response.headers)

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`)
      }

      return response.json()
    })
    .then(data => {
      console.log("Dream created successfully:", data)
      this.hideLoadingState()

      if (data.success) {
        alert("Dream saved")
        window.location.href = "/mydreams"
      } else {
        throw new Error(data.errors?.join(", ") || "Unknown error")
      }
    })
    .catch(error => {
      console.error("Error during save:", error)
      this.hideLoadingState()
      alert(`Error while saving: ${error.message}`)
    })
  })
}

  // FONCTION DIRECTE : Supprimer (appelée par le bouton)
  discardRecording() {
    this.cleanupRecording()
    alert("Recordind deleted")
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


    // Cacher tous les boutons
    this.hideAllButtons()
    this.buttonTarget.textContent = "Record"
  }

  showLoadingState(message) {
    const loader = document.createElement('div')
    loader.className = 'loading-overlay'
    loader.innerHTML = `
      <div class="spinner-border text-light" role="status">
        <span class="visually-hidden">Chargement...</span>
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
    let message = "An error occured"

    if (error.name === "NotAllowedError") {
      message = "Microphone access refused. Please, allow it in your browser"
    } else if (error.name === "NotFoundError") {
      message = "No microphone found on your device"
    }

    alert(message)
  }

  getMetaValue(name) {
    const element = document.head.querySelector(`meta[name="${name}"]`)
    return element?.getAttribute("content")
  }
}
