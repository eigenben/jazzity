import { Controller } from "@hotwired/stimulus"
import { Accidental, BarNote, Formatter, GhostNote, Renderer, Stave, StaveConnector, StaveNote, Voice } from "vexflow"

const STAVE_GAP = 90
const STAVE_HEIGHT = 120
const NOTE_SPACING = 56
const CLEF_SPACE = 70

// Renders chords as whole notes on a treble or grand staff.
//
//   <div data-controller="staff"
//        data-staff-chords-value='[["Eb/4", "G/4", "Bb/4", "D/5"]]'
//        data-staff-clef-value="treble"></div>
//
// On a grand staff, notes below middle C are written on the bass staff.
export default class extends Controller {
  static values = {
    chords: Array,
    clef: { type: String, default: "treble" },
    barlines: { type: Boolean, default: false }
  }

  async connect() {
    await document.fonts.load('30px "Bravura"')
    this.render()
  }

  chordsValueChanged() {
    if (this.rendered) this.render()
  }

  render() {
    const grand = this.clefValue === "grand"
    const width = CLEF_SPACE + Math.max(this.chordsValue.length, 2) * NOTE_SPACING
    const height = grand ? STAVE_HEIGHT + STAVE_GAP : STAVE_HEIGHT

    this.element.replaceChildren()
    const renderer = new Renderer(this.element, Renderer.Backends.SVG)
    renderer.resize(width, height)
    const context = renderer.getContext()
    context.setFillStyle("currentColor").setStrokeStyle("currentColor")

    const treble = new Stave(0, 10, width - 1).addClef("treble")
    const staves = grand ? [treble, new Stave(0, 10 + STAVE_GAP, width - 1).addClef("bass")] : [treble]
    Stave.formatBegModifiers(staves)
    staves.forEach((stave) => stave.setContext(context).draw())

    if (grand) {
      new StaveConnector(staves[0], staves[1]).setType("brace").setContext(context).draw()
      new StaveConnector(staves[0], staves[1]).setType("singleLeft").setContext(context).draw()
    }

    const clefs = grand ? ["treble", "bass"] : ["treble"]
    const voices = clefs.map((clef) => {
      const notes = this.chordsValue.map((chord) => this.noteFor(this.keysFor(chord, clef, grand), clef))
      return new Voice().setMode(Voice.Mode.SOFT).addTickables(this.withBarlines(notes))
    })

    const formatter = new Formatter()
    voices.forEach((voice) => formatter.joinVoices([voice]))
    formatter.format(voices, width - treble.getNoteStartX() - 16)
    voices.forEach((voice, i) => voice.draw(context, staves[i]))

    const svg = this.element.querySelector("svg")
    svg.setAttribute("viewBox", `0 0 ${width} ${height}`)
    svg.setAttribute("role", "img")
    svg.setAttribute("aria-label", this.description)
    svg.removeAttribute("width")
    svg.removeAttribute("height")
    svg.style.setProperty("--staff-width", `${width}px`)
    this.rendered = true
  }

  keysFor(chord, clef, grand) {
    if (!grand) return chord
    return chord.filter((key) => (octaveOf(key) < 4) === (clef === "bass"))
  }

  noteFor(keys, clef) {
    if (keys.length === 0) return new GhostNote({ duration: "w" })

    const note = new StaveNote({ keys, clef, duration: "w" })
    keys.forEach((key, index) => {
      const accidental = key.split("/")[0].slice(1)
      if (accidental) note.addModifier(new Accidental(accidental), index)
    })
    return note
  }

  withBarlines(notes) {
    if (!this.barlinesValue) return notes
    return notes.flatMap((note, i) => (i === 0 ? [note] : [new BarNote(), note]))
  }

  get description() {
    const names = this.chordsValue.map((chord) => chord.map((key) => key.split("/")[0]).join(" "))
    return `Staff notation: ${names.join(", ")}`
  }
}

function octaveOf(key) {
  return parseInt(key.split("/")[1], 10)
}
