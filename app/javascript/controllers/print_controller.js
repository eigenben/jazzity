import { Controller } from "@hotwired/stimulus"

// Opens the browser's print dialog, for a page laid out to print.
export default class extends Controller {
  print() {
    window.print()
  }
}
