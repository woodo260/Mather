import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "next", "display"]

  connect() {
    // Auto-focus the input when the controller connects (new question loaded)
    if (this.hasInputTarget) {
      this.inputTarget.focus()
    }
    this.syncDisplay()
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
    if (!this.isAllowedChar(event.key) && !["Backspace", "Delete", "Tab", "ArrowLeft", "ArrowRight"].includes(event.key)) {
      event.preventDefault()
    }
  }

  // Mobile keypad: append a digit/./- respecting the same rules as `filter`
  press(event) {
    const key = event.params.key
    const current = this.inputTarget.value

    if (key === "-") {
      // Minus only makes sense as a leading sign; tapping it again removes it
      this.inputTarget.value = current.startsWith("-") ? current.slice(1) : "-" + current
    } else if (key === "." && current.includes(".")) {
      return // ignore duplicate decimal point
    } else {
      this.inputTarget.value = current + key
    }

    this.syncDisplay()
  }

  backspace() {
    this.inputTarget.value = this.inputTarget.value.slice(0, -1)
    this.syncDisplay()
  }

  isAllowedChar(key) {
    return /[0-9.\-]/.test(key)
  }

  // Keep the mobile display in sync with the underlying (possibly hidden) input
  syncDisplay() {
    if (!this.hasDisplayTarget) return
    const value = this.inputTarget.value
    this.displayTarget.textContent = value === "" ? "Your answer…" : value
    this.displayTarget.classList.toggle("text-gray-400", value === "")
  }
}
