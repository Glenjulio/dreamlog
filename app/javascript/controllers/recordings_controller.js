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
        this.audioChunks = []
        this.mediaRecorder = new MediaRecorder(stream)

        this.mediaRecorder.ondataavailable = event => {
          if (event.data.size > 0) {
            this.audioChunks.push(event.data)
          }
        }

        this.mediaRecorder.onstop = () => {
          this.audioBlob = new Blob(this.audioChunks, { type: "audio/webm" })
          this.actionButtonsTarget.classList.remove("d-none")
        }

        this.buttonTarget.textContent = "Stop"
        this.mediaRecorder.start()
        console.log("Recording started")
      })
      .catch(error => {
        console.error("Microphone access error:", error)
        this.recording = false
        this.buttonTarget.textContent = "Record"

        if (error.name === "NotAllowedError") {
          alert("Accès microphone refusé. Veuillez autoriser l'accès dans les paramètres de votre navigateur.")
        } else {
          alert("impossible d'accéder au microphone. Veuillez vérifier les paramètres de votre navigateur.")
        }
      })
  }

  stopRecording() {
    if (this.mediaRecorder && this.mediaRecorder.state !== "inactive") {
      this.mediaRecorder.stop()
      this.buttonTarget.textContent = "Record"
    }
  }

  save() {
    if (!this.audioBlob) {
      alert("Enregistrer un rêve avant de le sauvegarder.");
      return;
    }

    const title = prompt("entrer un titre pour le rêve:");
    if (!title) {
      alert("Vous devez entrer un titre pour le rêve.")
      return
    }

    const file = new File([this.audioBlob], "recording.webm", {
      type: "audio/webm"
    });

    const upload = new DirectUpload(file, "/rails/active_storage/direct_uploads")

    upload.create((error, blob) => {
      if (error) {
        console.error("Direct upload failed:", error)
      } else {
        console.log("Direct upload successful:", blob)

        fetch("/dreams", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": this.getMetaValue("csrf-token")
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
            console.log("dream saved successfully");
            window.location.href = "/mydreams";
          } else {
            console.error("Failed to save dream:", response.statusText);
            alert("Le rêve n'a pas pu être sauvegardé. Veuillez réessayer.")
          }
        })
        .catch(error => {
          console.error("Error during save + transcription:", error)
          alert("An error occurred.")
        });
      }
    });
  }

  getMetaValue(name) {
    const element = document.head.querySelector(`meta[name="${name}"]`)
    return element?.getAttribute("content")
  }

  delete() {
    this.audioBlob = null
    this.actionButtonsTarget.classList.add("d-none")
    this.buttonTarget.textContent = "Record"
    alert("Enregistrement supprimé.")
  }
}
