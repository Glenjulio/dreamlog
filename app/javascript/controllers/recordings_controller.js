// app/javascript/controllers/recordings_controller.js
import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"

export default class extends Controller {
  static targets = ["button", "actionButtons", "save", "delete"]

  connect() {
    this.recording = false
    this.mediaRecorder = null
    this.audioChunks = []
    this.signedId = null
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
    console.log("▶ Attempting to access microphone...")

    navigator.mediaDevices.getUserMedia({ audio: true })
      .then(stream => {
        console.log("✅ Microphone access granted")

        this.audioChunks = []
        this.mediaRecorder = new MediaRecorder(stream)

        this.mediaRecorder.ondataavailable = event => {
          if (event.data.size > 0) {
            this.audioChunks.push(event.data)
          }
        }

        this.mediaRecorder.onstop = () => {
          console.log("🛑 Recording stopped")
          this.audioBlob = new Blob(this.audioChunks, { type: "audio/webm" })
          const file = new File([this.audioBlob], "recording.webm", { type: "audio/webm" })
          this.uploadAudio(file)
        }

        this.buttonTarget.innerText = "Stop"
        this.mediaRecorder.start()
        console.log("🎙️ Recording started")
      })
      .catch(error => {
        console.error("❌ Microphone access failed:", error)
      })
  }

  stopRecording() {
    this.mediaRecorder.stop()
    this.buttonTarget.innerText = "Record"
    this.actionButtonsTarget.classList.remove("d-none")
    console.log("🛑 Recording stopped")
  }

  uploadAudio(file) {
    console.log("⬆️ Uploading file...", file)

    const upload = new DirectUpload(file, "/rails/active_storage/direct_uploads")

    upload.create((error, blob) => {
      if (error) {
        console.error("❌ Upload failed", error)
      } else {
        console.log("✅ Upload success", blob)
        this.signedId = blob.signed_id
      }
    })
  }

  async save() {
    if (!this.audioBlob) {
      alert("No recording to save")
      return
    }

    const title = prompt("Enter a title for your dream:")
    if (!title) {
      alert("Dream not saved (title is required)")
      return
    }

    const file = new File([this.audioBlob], "recording.webm", {
      type: "audio/webm"
    })

    const upload = new DirectUpload(file, "/rails/active_storage/direct_uploads")

    upload.create((error, blob) => {
      if (error) {
        console.error("❌ Upload failed", error)
        alert("Upload failed")
      } else {
        console.log("✅ Upload success", blob)

        const formData = new FormData()
        formData.append("dream[title]", title)
        formData.append("dream[tags]", "voice")
        formData.append("dream[private]", false)
        formData.append("dream[audio]", blob.signed_id)
        // formData.append("dream[transcription_attributes][content]", "Voice recorded dream")

        console.log("📤 Sending formData to /dreams...")

        fetch("/dreams", {
          method: "POST",
          headers: {
            "X-CSRF-Token": this.getMetaValue("csrf-token"),
            "Accept": "application/json" // ✅ important
          },
          body: formData
        })
          .then(response => {
            console.log("📦 Raw response from /dreams:", response)
            return response.json()
          })
          .then(data => {
            console.log("📨 JSON response from /dreams:", data)

            if (data.success && data.id) {
              console.log(`🚀 Launching transcription for dream #${data.id}`)

              return fetch(`/dreams/${data.id}/transcribe`, {
                method: "POST",
                headers: {
                  "X-CSRF-Token": this.getMetaValue("csrf-token")
                }
              }).then(() => {
                console.log(`✅ Redirecting to /dreams/${data.id}/transcription`)
                window.location.href = `/dreams/${data.id}/transcription`
              })
            } else {
              console.error("❌ Failed to save dream (data returned, but not valid):", data)
              alert("Dream could not be saved: " + (data.errors?.join(", ") || "Unknown error"))
            }
          })
          .catch(error => {
            console.error("❌ Server error when creating dream:", error)
            alert("Error saving dream (see console for details)")
          })
      }
    })
  }

  getMetaValue(name) {
    const element = document.head.querySelector(`meta[name="${name}"]`)
    return element?.getAttribute("content")
  }

  delete() {
    this.signedId = null
    this.actionButtonsTarget.classList.add("d-none")
    alert("🗑️ Recording deleted")
  }
}
