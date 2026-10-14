import { Controller } from "@hotwired/stimulus"

// A piano keyboard drawn by keyboard_tag (app/helpers/keyboard_helper.rb).
// A player marks the chord it's sounding with `show`, lights up single
// notes with `sound`, and puts the keyboard back as it was with `reset`.
export default class extends Controller {
  connect() {
    this.initial = {
      label: this.element.getAttribute("aria-label"),
      keys: this.keys.map((key) => {
        const text = key.querySelector("text")
        return { classes: key.getAttribute("class"), text: text.textContent, textClasses: text.getAttribute("class") }
      })
    }
  }

  get keys() {
    return [...this.element.querySelectorAll(".keyboard-key")]
  }

  // Marks a chord: MIDI notes for each hand, and their names (as in "Eb4"),
  // left hand first.
  show({ left = [], right = [], names = [] }) {
    const hands = new Map([...left.map((midi) => [midi, "left"]), ...right.map((midi) => [midi, "right"])])
    const labels = new Map([...left, ...right].map((midi, i) => [midi, names[i]]))

    this.keys.forEach((key) => {
      const midi = Number(key.dataset.midi)
      const hand = hands.get(midi)
      const text = key.querySelector("text")

      key.classList.toggle("is-left", hand === "left")
      key.classList.toggle("is-right", hand === "right")
      key.classList.remove("is-sounding")
      text.textContent = hand ? letters(labels.get(midi)) : key.dataset.default || ""
      text.classList.toggle("keyboard-octave", !hand)
    })

    const leftNames = names.slice(0, left.length).join(" ")
    const rightNames = names.slice(left.length).join(" ")
    const marked = [leftNames && `left hand ${leftNames}`, rightNames && (leftNames ? `right hand ${rightNames}` : rightNames)].filter(Boolean)
    this.element.setAttribute("aria-label", ["Piano keyboard", marked.join(", ")].filter(Boolean).join(": "))
  }

  // Lights up the keys of the notes sounding now.
  sound(midis) {
    const sounding = new Set(midis)
    this.keys.forEach((key) => key.classList.toggle("is-sounding", sounding.has(Number(key.dataset.midi))))
  }

  reset() {
    if (!this.initial) return

    this.keys.forEach((key, i) => {
      const initial = this.initial.keys[i]
      const text = key.querySelector("text")
      key.setAttribute("class", initial.classes)
      text.textContent = initial.text
      if (initial.textClasses) text.setAttribute("class", initial.textClasses)
      else text.removeAttribute("class")
    })
    this.element.setAttribute("aria-label", this.initial.label)
  }
}

// A note's name without its octave, with real sharp and flat signs.
function letters(name = "") {
  return name.replace(/-?\d+$/, "").replace(/(?<=.)b/g, "♭").replace(/#/g, "♯")
}
