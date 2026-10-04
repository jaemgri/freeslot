import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]
  static values = { url: String, title: String, text: String }

  connect() {
    // Only show the button where the browser has a share sheet (phones, Safari).
    if (navigator.share) this.buttonTarget.hidden = false
  }

  async share() {
    try {
      await navigator.share({ title: this.titleValue, text: this.textValue, url: this.urlValue })
    } catch (error) {
      // AbortError just means they closed the share sheet without picking an app.
      if (error.name !== "AbortError") console.error(error)
    }
  }
}
