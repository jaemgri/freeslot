import { Controller } from "@hotwired/stimulus"

const SELECTED = ["ring-2", "ring-inset", "ring-ink"]

export default class extends Controller {
  static values = { url: String }

  start(event) {
    const cell = this.cellFrom(event)
    if (!cell || event.button !== 0) return

    this.adding = cell.dataset.mine !== "true"
    this.pending = new Set()

    // Touch: wait for the finger to lift. If the browser decides it was a
    // scroll instead, it fires pointercancel and nothing gets selected.
    if (event.pointerType === "touch") {
      this.touchCell = cell
      return
    }

    event.preventDefault() // stop text selection while dragging
    this.dragging = true
    this.mark(cell)
  }

  move(event) {
    if (!this.dragging) return
    const cell = this.cellFrom(event)
    if (cell) this.mark(cell)
  }

  end(event) {
    if (this.touchCell) {
      if (this.cellFrom(event) === this.touchCell) this.mark(this.touchCell)
      this.touchCell = null
    }
    this.dragging = false
    this.save()
  }

  cancel() {
    this.touchCell = null
    this.dragging = false
    this.save()
  }

  // Enter/Space on a focused cell fires a click with detail 0.
  // Mouse and touch clicks have detail >= 1 and are handled above.
  key(event) {
    if (event.detail !== 0) return
    const cell = this.cellFrom(event)
    if (!cell) return

    this.adding = cell.dataset.mine !== "true"
    this.pending = new Set()
    this.mark(cell)
    this.save()
  }

  mark(cell) {
    if (this.pending.has(cell.dataset.slot)) return
    this.pending.add(cell.dataset.slot)

    cell.dataset.mine = this.adding
    cell.setAttribute("aria-pressed", this.adding)
    SELECTED.forEach((name) => cell.classList.toggle(name, this.adding))
  }

  async save() {
    if (!this.pending?.size) return
    const slots = [...this.pending]
    this.pending = new Set()

    try {
      const response = await fetch(this.urlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content
        },
        body: JSON.stringify({ slots, available: this.adding })
      })
      if (!response.ok) throw new Error(`HTTP ${response.status}`)
    } catch (error) {
      console.error("Saving availability failed:", error)
    }

    // Pull the true state from the server. Because of turbo_refreshes_with
    // in the layout, this morphs in place and keeps the scroll position.
    window.Turbo.visit(window.location.href, { action: "replace" })
  }

  cellFrom(event) {
    if (!(event.target instanceof Element)) return null
    const cell = event.target.closest("[data-slot]")
    return cell && this.element.contains(cell) ? cell : null
  }
}
