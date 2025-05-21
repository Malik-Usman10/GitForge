import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["previewTitle", "previewContent"]

  connect() {
    // Listen for file selection events
    this.element.addEventListener('file-selected', this.handleFileSelection.bind(this))
  }

  disconnect() {
    this.element.removeEventListener('file-selected', this.handleFileSelection.bind(this))
  }

  async handleFileSelection(event) {
    const fileName = event.detail.fileName
    const response = await fetch(`/repositories/${this.element.dataset.repositoryId}/file_content?path=${encodeURIComponent(fileName)}`)
    const data = await response.json()

    if (data.success) {
      this.previewTitleTarget.textContent = fileName
      this.previewContentTarget.innerHTML = this.formatContent(data.content, fileName)
    } else {
      this.previewTitleTarget.textContent = "Error"
      this.previewContentTarget.innerHTML = `<div class="text-red-500">${data.error}</div>`
    }
  }

  formatContent(content, fileName) {
    if (fileName.toLowerCase().endsWith('.md')) {
      return this.markdownToHtml(content)
    } else {
      return `<pre class="bg-gray-800 p-4 rounded-lg overflow-x-auto"><code>${this.escapeHtml(content)}</code></pre>`
    }
  }

  markdownToHtml(content) {
    // Use the same markdown renderer as the server
    return content
  }

  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }

  confirmDelete(event) {
    if (!confirm("Are you sure you want to delete this repository? This action cannot be undone.")) {
      event.preventDefault()
    }
  }
} 