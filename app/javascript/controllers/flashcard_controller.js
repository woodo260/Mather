import { Controller } from "@hotwired/stimulus"

// Anki-style flip card: show the front, reveal the back, then self-grade.
// Keyboard: Space/Enter reveals; once revealed, 1–4 pick Again/Hard/Good/Easy.
export default class extends Controller {
  static targets = ["reveal", "answer", "rate"]

  connect() {
    this.revealed = false
    this.onKeydown = this.handleKey.bind(this)
    document.addEventListener("keydown", this.onKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.onKeydown)
  }

  reveal() {
    if (this.revealed) return
    this.revealed = true
    this.revealTarget.hidden = true
    this.answerTarget.hidden = false
  }

  handleKey(event) {
    // Ignore keystrokes while typing in a field.
    const tag = event.target.tagName
    if (tag === "INPUT" || tag === "TEXTAREA") return

    if (!this.revealed) {
      if (event.key === " " || event.key === "Enter") {
        event.preventDefault()
        this.reveal()
      }
      return
    }

    const button = this.rateTargets.find((b) => b.dataset.ratingKey === event.key)
    if (button) {
      event.preventDefault()
      button.click()
    }
  }
}
