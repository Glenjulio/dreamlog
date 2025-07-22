import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"

export default class extends Controller {
  static targets = ["button", "actionButtons", "save", "delete"]

  connect() {
    this.recording = false
    this.mediaRecorder = null
    this.audioChunks = []
    this.audioBlob = null
  }

  toggle() {
    this.recording = !this.recording

    if (this.recording) {
      this.startRecording()
    } else {
      this.stopRecording()
    }
  }

  startRecording() {
    navigator.mediaDevices.getUserMedia({ audio: true })
      .then(stream => {
        this.mediaRecorder = new MediaRecorder(stream)
        this.audioChunks = []

        this.mediaRecorder.ondataavailable = event => {
          if (event.data.size > 0) {
            this.audioChunks.push(event.data)
          }
        }

        this.mediaRecorder.onstop = () => {
          this.audioBlob = new Blob(this.audioChunks, { type: "audio/webm" })
          this.actionButtonsTarget.classList.remove("d-none")
        }

        this.mediaRecorder.start()
        this.buttonTarget.textContent = "Stop"
      })
      .catch(error => {
        console.error("Microphone access error:", error)
        alert("Microphone access is required.")
      })
  }

  stopRecording() {
    if (this.mediaRecorder && this.mediaRecorder.state !== "inactive") {
      this.mediaRecorder.stop()
      this.buttonTarget.textContent = "Record"
    }
  }

  delete() {
    this.audioBlob = null
    this.actionButtonsTarget.classList.add("d-none")
    this.buttonTarget.textContent = "Record"
  }

  save() {
    if (!this.audioBlob) {
      alert("No audio recorded.")
      return
    }

    const title = prompt("Enter a title for your dream:")
    if (!title) {
      alert("You must enter a title.")
      return
    }

    const formData = new FormData()
    formData.append("audio", this.audioBlob, "recording.webm")
    formData.append("title", title)

    fetch("/dreams/upload_audio", {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: formData
    })
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          const dreamId = data.id

          return fetch(`/dreams/${dreamId}/transcribe`, {
            method: "POST",
            headers: {
              "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
            }
          })
            .then(resp => {
              if (!resp.ok) throw new Error("Transcription failed")
              window.location.href = `/dreams/${dreamId}/transcription`
            })
        } else {
          alert("Upload failed: " + data.error)
        }
      })
      .catch(error => {
        console.error("Error during save + transcription:", error)
        alert("An error occurred.")
      })
  }
}
