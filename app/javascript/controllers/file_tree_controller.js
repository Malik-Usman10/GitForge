import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]

  connect() {
    // Initialize the first level of directories as expanded
    if (this.element.closest('.file-tree').parentElement === null) {
      this.contentTarget.classList.remove('hidden')
    }
  }

  toggle(event) {
    event.preventDefault()
    const button = event.currentTarget
    const content = this.contentTarget
    
    if (content.classList.contains('hidden')) {
      content.classList.remove('hidden')
      button.classList.add('rotate-90')
    } else {
      content.classList.add('hidden')
      button.classList.remove('rotate-90')
    }
  }
} 