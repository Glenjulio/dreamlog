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

        // Réinitialiser l'état en cas d'erreur
        this.recording = false
        this.buttonTarget.innerText = "Record"

        // Message utilisateur plus clair
        if (error.name === 'NotAllowedError') {
          alert("Microphone access denied. Please allow microphone access in your browser settings and try again.")
        } else {
          alert("Unable to access microphone. Please check your browser settings.")
        }
      })
  }

  stopRecording() {
    // Vérification pour éviter l'erreur null
    if (this.mediaRecorder && this.mediaRecorder.state !== 'inactive') {
      this.mediaRecorder.stop()
    }

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
      alert("No recording to save");
      return;
    }

    const title = prompt("Enter a title for your dream:");
    if (!title) {
      alert("Dream not saved (title is required)");
      return;
    }

    const file = new File([this.audioBlob], "recording.webm", {
      type: "audio/webm"
    });

    const upload = new DirectUpload(file, "/rails/active_storage/direct_uploads");

    upload.create((error, blob) => {
      if (error) {
        console.error("❌ Upload failed", error);
      } else {
        console.log("✅ Upload success", blob);

        fetch("/dreams", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": this.getMetaValue("csrf-token"),
          },
          body: JSON.stringify({
            dream: {
              title: title,
              tags: "voice",
              private: false,
              audio: blob.signed_id
            }
          })
        })
        .then(response => {
          if (response.ok) {
            console.log("🎉 Dream saved!");
            window.location.href = "/mydreams";
          } else {
            console.error("❌ Failed to save dream", response.statusText);
            alert("Dream could not be saved");
          }
        })
        .catch(error => {
          console.error("❌ Server error", error);
          alert("Error saving dream");
        });
      }
    });
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
