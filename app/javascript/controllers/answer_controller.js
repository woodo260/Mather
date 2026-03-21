import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "next"]

  connect() {
    // Auto-focus the input when the controller connects (new question loaded)
    if (this.hasInputTarget) {
      this.inputTarget.focus()
    }
  }

  // Submit on Enter key
  submit(event) {
    if (event.key === "Enter") {
      event.preventDefault()
      this.element.requestSubmit()
    }
  }

  // Navigate to next question on Enter when feedback is shown
  next(event) {
    if (event.key === "Enter" && this.hasNextTarget) {
      event.preventDefault()
      this.nextTarget.click()
    }
  }

  // Restrict to numeric input (digits, decimal point, minus sign)
  filter(event) {
    const allowed = /[0-9.\-]/
    if (!allowed.test(event.key) && !["Backspace", "Delete", "Tab", "ArrowLeft", "ArrowRight"].includes(event.key)) {
      event.preventDefault()
    }
  }
}
