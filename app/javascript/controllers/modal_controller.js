import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  connect() {
    // Add keydown event listener to close modal on Escape key
    document.addEventListener("keydown", this.handleKeyDown.bind(this))
  }

  disconnect() {
    // Clean up event listener
    document.removeEventListener("keydown", this.handleKeyDown.bind(this))
  }

  open(event) {
    this.containerTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
  }

  close(event) {
    if (event.target === event.currentTarget || event.currentTarget.dataset.action.includes("modal#close")) {
      this.containerTarget.classList.add("hidden")
      document.body.classList.remove("overflow-hidden")
    }
  }

  handleKeyDown(event) {
    if (event.key === "Escape" && !this.containerTarget.classList.contains("hidden")) {
      this.close(event)
    }
  }
} 