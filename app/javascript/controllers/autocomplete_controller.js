import { Controller } from "@hotwired/stimulus"

// Suggests chords, scales and progressions as the user types into the
// search field, in a listbox under it (the ARIA combobox pattern). Up and
// down move through the suggestions, Enter goes to the one picked (or
// searches for the text when none is), and Escape closes the list.
//
// The suggestions come from `url` as JSON: [{label, detail, url}, ...].
export default class extends Controller {
  static targets = ["input", "listbox", "status"]
  static values = { url: String }

  connect() {
    this.suggestions = []
    this.active = -1
  }

  disconnect() {
    clearTimeout(this.timeout)
    this.request?.abort()
    this.close()
  }

  suggest() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => this.fetchSuggestions(), 120)
  }

  async fetchSuggestions() {
    const query = this.inputTarget.value.trim()
    this.request?.abort()
    if (query.length < 2) return this.show([])

    this.request = new AbortController()
    try {
      const url = `${this.urlValue}?${new URLSearchParams({ q: query })}`
      const response = await fetch(url, { signal: this.request.signal, headers: { Accept: "application/json" } })
      if (response.ok) this.show(await response.json())
    } catch (error) {
      if (error.name !== "AbortError") throw error
    }
  }

  show(suggestions) {
    this.suggestions = suggestions
    this.active = -1
    this.listboxTarget.replaceChildren(...suggestions.map((suggestion, index) => this.option(suggestion, index)))
    this.statusTarget.textContent = suggestions.length ? `${suggestions.length} suggestion${suggestions.length === 1 ? "" : "s"}, use the arrow keys to choose` : ""
    if (suggestions.length && document.activeElement === this.inputTarget) this.open()
    else this.close()
  }

  option(suggestion, index) {
    const option = document.createElement("li")
    option.id = `${this.listboxTarget.id}-${index}`
    option.className = "search-suggestion"
    option.setAttribute("role", "option")
    option.setAttribute("aria-selected", "false")

    const label = document.createElement("span")
    label.className = "search-suggestion-label"
    label.textContent = suggestion.label
    const detail = document.createElement("span")
    detail.className = "search-suggestion-detail"
    detail.textContent = ` — ${suggestion.detail}`
    option.append(label, detail)

    // Keep focus in the field so the click lands before the list closes.
    option.addEventListener("mousedown", (event) => event.preventDefault())
    option.addEventListener("mousemove", () => this.highlight(index))
    option.addEventListener("click", () => this.go(index))
    return option
  }

  navigate(event) {
    const count = this.suggestions.length

    switch (event.key) {
      case "ArrowDown":
        if (!count) return
        event.preventDefault()
        this.open()
        this.highlight(this.active < count - 1 ? this.active + 1 : 0)
        break
      case "ArrowUp":
        if (!count) return
        event.preventDefault()
        this.open()
        this.highlight(this.active > 0 ? this.active - 1 : count - 1)
        break
      case "Enter":
        if (this.isOpen && this.active >= 0) {
          event.preventDefault()
          this.go(this.active)
        }
        break
      case "Escape":
        if (this.isOpen) {
          event.preventDefault()
          this.close()
        }
        break
    }
  }

  highlight(index) {
    this.active = index
    this.listboxTarget.querySelectorAll("[role=option]").forEach((option, i) => {
      option.setAttribute("aria-selected", i === index ? "true" : "false")
      if (i === index) option.scrollIntoView({ block: "nearest" })
    })
    this.inputTarget.setAttribute("aria-activedescendant", `${this.listboxTarget.id}-${index}`)
  }

  go(index) {
    const { url } = this.suggestions[index]
    this.close()
    if (window.Turbo) window.Turbo.visit(url)
    else window.location.assign(url)
  }

  open() {
    this.listboxTarget.hidden = false
    this.inputTarget.setAttribute("aria-expanded", "true")
  }

  close() {
    this.active = -1
    this.listboxTarget.hidden = true
    this.inputTarget.setAttribute("aria-expanded", "false")
    this.inputTarget.removeAttribute("aria-activedescendant")
  }

  get isOpen() {
    return !this.listboxTarget.hidden
  }
}
