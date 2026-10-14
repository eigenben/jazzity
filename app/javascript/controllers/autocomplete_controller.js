import { Controller } from "@hotwired/stimulus"

// Suggests matching chords, scales and progressions in a <datalist> as the
// user types into the search field.
export default class extends Controller {
  static targets = ["input", "suggestions"]
  static values = { url: String }

  disconnect() {
    clearTimeout(this.timeout)
    this.request?.abort()
  }

  suggest() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => this.fetchSuggestions(), 150)
  }

  async fetchSuggestions() {
    const query = this.inputTarget.value.trim()
    if (query.length < 2) return this.suggestionsTarget.replaceChildren()

    this.request?.abort()
    this.request = new AbortController()

    try {
      const url = `${this.urlValue}?${new URLSearchParams({ q: query })}`
      const response = await fetch(url, { signal: this.request.signal, headers: { Accept: "application/json" } })
      const names = await response.json()
      this.suggestionsTarget.replaceChildren(...names.map((name) => new Option(name)))
    } catch (error) {
      if (error.name !== "AbortError") throw error
    }
  }
}
