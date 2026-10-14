import { Controller } from "@hotwired/stimulus"

// Submits the surrounding form as soon as one of its fields changes.
export default class extends Controller {
  submit() {
    this.element.requestSubmit()
  }
}
