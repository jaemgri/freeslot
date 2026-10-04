import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "button"]

  async copy() {
    this.original ??= this.buttonTarget.textContent.trim()
    await navigator.clipboard.writeText(this.sourceTarget.value)
    this.buttonTarget.textContent = "copied!"
    clearTimeout(this.timer)
    this.timer = setTimeout(() => (this.buttonTarget.textContent = this.original), 2000)
  }
}
