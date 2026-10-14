import { Controller } from "@hotwired/stimulus"
import { Accidental, BarNote, Formatter, GhostNote, Renderer, Stave, StaveConnector, StaveNote, Voice } from "vexflow"

const STAVE_GAP = 80
const NOTE_SPACING = 44
const MEASURE_SPACING = 64
const CLEF_SPACE = 70
const PADDING = 4

// Renders chords as whole notes on a treble or grand staff.
//
//   <div data-controller="staff"
//        data-staff-chords-value='[["Eb/4", "G/4", "Bb/4", "D/5"]]'
//        data-staff-clef-value="treble"></div>
//
// On a grand staff, notes below middle C are written on the bass staff. The
// drawing is cropped to what was actually engraved (brace, ledger lines and
// all) and scales down to fit its container.
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
    this.element.replaceChildren()
    if (this.chordsValue.length === 0) return

    const grand = this.clefValue === "grand"
    const clefs = grand ? ["treble", "bass"] : ["treble"]
    const voices = clefs.map((clef) => {
      const notes = this.chordsValue.map((chord) => this.noteFor(this.keysFor(chord, clef, grand), clef))
      return new Voice().setMode(Voice.Mode.SOFT).addTickables(this.withBarlines(notes))
    })

    // Give each chord its base spacing, but never less than the formatter
    // needs to keep stacked accidentals clear of their neighbours.
    const formatter = new Formatter()
    voices.forEach((voice) => formatter.joinVoices([voice]))
    const spacing = this.barlinesValue ? MEASURE_SPACING : NOTE_SPACING
    const noteWidth = Math.max(Math.max(this.chordsValue.length, 2) * spacing, formatter.preCalculateMinTotalWidth(voices) * 1.25)
    const width = CLEF_SPACE + noteWidth

    const renderer = new Renderer(this.element, Renderer.Backends.SVG)
    renderer.resize(width, 300)
    const context = renderer.getContext()
    context.setFillStyle("currentColor").setStrokeStyle("currentColor")

    const staves = [new Stave(0, 0, width).addClef("treble")]
    if (grand) staves.push(new Stave(0, STAVE_GAP, width).addClef("bass"))
    Stave.formatBegModifiers(staves)
    staves.forEach((stave) => stave.setContext(context).draw())

    formatter.format(voices, width - staves[0].getNoteStartX() - spacing / 3)
    voices.forEach((voice, i) => voice.draw(context, staves[i]))

    if (grand) this.connectStaves(context, ...staves, voices[0])

    this.fitToDrawing(this.element.querySelector("svg"))
    this.rendered = true
  }

  // Joins the treble and bass staves the way a piano score does: a brace and
  // line at the start, and barlines that run through the gap between them.
  connectStaves(context, treble, bass, trebleVoice) {
    for (const type of ["brace", "singleLeft", "singleRight"]) {
      new StaveConnector(treble, bass).setType(type).setContext(context).draw()
    }

    const top = treble.getBottomLineBottomY()
    const gap = bass.getTopLineTopY() - top
    trebleVoice.getTickables()
      .filter((tickable) => tickable instanceof BarNote)
      .forEach((barNote) => context.fillRect(barNote.getAbsoluteX(), top, 1, gap))
  }

  // VexFlow sizes the SVG to the canvas it was given, which crops anything
  // drawn outside it and pins the element to a fixed pixel size. Instead,
  // frame the viewBox around the engraving and let CSS scale it.
  fitToDrawing(svg) {
    const box = inkBounds(svg)
    if (!box) return // Not laid out (e.g. hidden); keep VexFlow's own sizing.

    const x = Math.floor(box.left) - PADDING
    const y = Math.floor(box.top) - PADDING
    const width = Math.ceil(box.right - box.left) + PADDING * 2
    const height = Math.ceil(box.bottom - box.top) + PADDING * 2

    svg.setAttribute("viewBox", `${x} ${y} ${width} ${height}`)
    svg.setAttribute("role", "img")
    svg.setAttribute("aria-label", this.description)
    svg.removeAttribute("width")
    svg.removeAttribute("height")
    svg.removeAttribute("style")
    svg.style.setProperty("--staff-width", `${width}px`)
    this.element.style.removeProperty("width")
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

// The area actually inked by an engraving. getBBox() on a music glyph returns
// the font's whole em box (several staves tall in Bravura), so glyphs are
// measured with canvas text metrics and combined with the drawn shapes.
function inkBounds(svg) {
  const bounds = { left: Infinity, top: Infinity, right: -Infinity, bottom: -Infinity }
  const include = (left, top, right, bottom) => {
    bounds.left = Math.min(bounds.left, left)
    bounds.top = Math.min(bounds.top, top)
    bounds.right = Math.max(bounds.right, right)
    bounds.bottom = Math.max(bounds.bottom, bottom)
  }

  svg.querySelectorAll("path, rect").forEach((shape) => {
    const box = shape.getBBox()
    if (box.width || box.height) include(box.x, box.y, box.x + box.width, box.y + box.height)
  })

  const metrics = inkBounds.context ||= document.createElement("canvas").getContext("2d")
  svg.querySelectorAll("text").forEach((text) => {
    const style = getComputedStyle(text)
    metrics.font = `${style.fontStyle} ${style.fontWeight} ${style.fontSize} ${style.fontFamily}`
    const ink = metrics.measureText(text.textContent)
    const x = parseFloat(text.getAttribute("x"))
    const y = parseFloat(text.getAttribute("y"))
    include(x - ink.actualBoundingBoxLeft, y - ink.actualBoundingBoxAscent, x + ink.actualBoundingBoxRight, y + ink.actualBoundingBoxDescent)
  })

  return bounds.right > bounds.left ? bounds : null
}
