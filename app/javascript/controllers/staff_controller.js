import { Controller } from "@hotwired/stimulus"
import { Accidental, BarlineType, Dot, Formatter, GhostNote, Renderer, Stave, StaveConnector, StaveNote, Voice } from "vexflow"

const STAVE_GAP = 90 // From the top of the treble staff to the top of the bass staff
const SYSTEM_GAP = 28 // Between one line of music and the next
const NOTE_SPACING = 44
const MEASURE_SPACING = 64
const NOTE_END_GAP = 18
const PADDING = 4
const MIN_BAR_WIDTH = 150 // On screen, before a long progression wraps onto another line
const MAX_BARS_PER_LINE = 4
const SYMBOL_FONT = { family: "Instrument Sans, system-ui, sans-serif", size: 14, weight: "600" }
const SYMBOL_GAP = 10
const DURATIONS = { 1: "q", 2: "h", 3: "hd", 4: "w" }

// Renders chords on a treble or grand staff.
//
//   <div data-controller="staff"
//        data-staff-chords-value='[["Eb/4", "G/4", "Bb/4", "D/5"]]'
//        data-staff-clef-value="treble"></div>
//
// Each chord is either a list of notes or an object that says which staff
// each note goes on, with an optional chord symbol to write above it and
// its length in beats:
//
//   {"symbol": "Dm7", "bass": ["D/2"], "treble": ["C/4", "E/4", "F/4", "A/4"], "beats": 2}
//
// A plain list on a grand staff is split at middle C. A grand staff leaves
// out a staff none of the chords use, unless `full-grand` is set. With barlines, chords
// are grouped into bars of `beats-per-bar` beats (a bar each when they don't
// give their beats), and long runs of bars wrap onto several lines, as many
// to the line as fit the container. The drawing is cropped to what was
// actually engraved (brace, ledger lines and all) and scales down to fit.
export default class extends Controller {
  static values = {
    chords: Array,
    clef: { type: String, default: "treble" },
    barlines: { type: Boolean, default: false },
    beatsPerBar: { type: Number, default: 4 },
    fullGrand: { type: Boolean, default: false }
  }

  async connect() {
    await Promise.all([
      document.fonts.load('30px "Bravura"'),
      document.fonts.load(`${SYMBOL_FONT.weight} ${SYMBOL_FONT.size}px ${SYMBOL_FONT.family}`)
    ])
    this.render()

    this.resizeObserver = new ResizeObserver(() => {
      if (this.rendered && this.barsPerLine !== this.renderedBarsPerLine) this.render()
    })
    this.resizeObserver.observe(this.element)
  }

  disconnect() {
    this.resizeObserver?.disconnect()
  }

  chordsValueChanged() {
    if (this.rendered) this.render()
  }

  render() {
    this.element.replaceChildren()
    if (this.chordsValue.length === 0) return

    const chords = this.chordsValue.map((chord) => this.normalize(chord))
    const clefs = this.clefsFor(chords)
    const measures = this.measuresFor(chords).map((chords) => this.engrave(chords, clefs))
    const lines = this.linesFor(measures)

    const chrome = { first: this.staveChrome(clefs, true), other: this.staveChrome(clefs, false) }
    const naturalWidth = (line) => line.reduce((sum, measure, i) => sum + measure.width + (i === 0 ? chrome.first : chrome.other), 0)
    const width = Math.max(...lines.map(naturalWidth))
    const lineHeight = 400

    const renderer = new Renderer(this.element, Renderer.Backends.SVG)
    renderer.resize(width + 20, lineHeight * lines.length)
    const context = renderer.getContext()
    context.setFillStyle("currentColor").setStrokeStyle("currentColor")

    const groups = lines.map((line, i) => {
      const group = context.openGroup("system")
      const stretch = (width - naturalWidth(line)) / line.reduce((sum, measure) => sum + measure.width, 0)
      this.drawLine(context, line, clefs, lineHeight * i + 120, stretch, i === lines.length - 1)
      context.closeGroup()
      return group
    })

    this.stack(this.element.querySelector("svg"), groups)
    this.renderedBarsPerLine = this.barsPerLine
    this.rendered = true
  }

  // A chord as {treble, bass, symbol, beats}.
  normalize(chord) {
    if (!Array.isArray(chord)) return { treble: chord.treble || [], bass: chord.bass || [], symbol: chord.symbol, beats: chord.beats, explicit: true }
    if (this.clefValue !== "grand") return { treble: chord, bass: [] }

    return { treble: chord.filter((key) => octaveOf(key) >= 4), bass: chord.filter((key) => octaveOf(key) < 4) }
  }

  // The staves to draw. A grand staff whose chords say where their notes go
  // leaves out a staff none of them use, unless it's asked to stay whole.
  clefsFor(chords) {
    if (this.clefValue !== "grand") return ["treble"]
    if (this.fullGrandValue || !chords.every((chord) => chord.explicit)) return ["treble", "bass"]

    const clefs = ["treble", "bass"].filter((clef) => chords.some((chord) => chord[clef].length > 0))
    return clefs.length > 0 ? clefs : ["treble", "bass"]
  }

  // Splits the chords into bars, restriking a chord that runs over a barline.
  // Without barlines, everything is one bar of whole notes.
  measuresFor(chords) {
    if (!this.barlinesValue) return [chords.map((chord) => ({ ...chord, duration: "w" }))]

    const perBar = this.beatsPerBarValue
    const measures = [[]]
    let filled = 0

    chords.forEach((chord) => {
      let remaining = chord.beats || perBar
      let symbol = chord.symbol

      while (remaining > 0) {
        const beats = Math.min(remaining, perBar - filled)
        measures[measures.length - 1].push({ ...chord, symbol, duration: DURATIONS[beats] || "w" })
        remaining -= beats
        filled += beats
        symbol = null

        if (filled >= perBar) {
          measures.push([])
          filled = 0
        }
      }
    })

    return measures.filter((measure) => measure.length > 0)
  }

  // Lines of bars, as even as possible: 12 bars at four to the line are
  // three lines of four, and 5 bars are lines of three and two. A few bars
  // stay on one line and shrink to fit instead.
  linesFor(measures) {
    if (measures.length <= MAX_BARS_PER_LINE) return [measures]

    const count = Math.ceil(measures.length / this.barsPerLine)
    const perLine = Math.ceil(measures.length / count)
    const lines = []
    for (let i = 0; i < measures.length; i += perLine) lines.push(measures.slice(i, i + perLine))
    return lines
  }

  get barsPerLine() {
    const available = this.element.clientWidth || MIN_BAR_WIDTH * MAX_BARS_PER_LINE
    return Math.max(2, Math.min(MAX_BARS_PER_LINE, Math.floor(available / MIN_BAR_WIDTH)))
  }

  // Builds the notes of a bar on each staff and works out how much room
  // they need: enough for the formatter, for the chord symbols, and never
  // less than a base spacing per chord.
  engrave(chords, clefs) {
    const voices = clefs.map((clef) => {
      const accidentals = new Map()
      const notes = chords.map((chord) => this.noteFor(chord[clef], clef, chord.duration, accidentals))
      return new Voice().setMode(Voice.Mode.SOFT).addTickables(notes)
    })

    const formatter = new Formatter()
    voices.forEach((voice) => formatter.joinVoices([voice]))
    const spacing = this.barlinesValue ? MEASURE_SPACING : NOTE_SPACING
    const symbols = chords.map((chord) => chord.symbol && formatSymbol(chord.symbol))
    const symbolsWidth = symbols.reduce((sum, symbol) => sum + (symbol ? textWidth(symbol) + SYMBOL_GAP : 0), 0)
    const minimum = Math.max(Math.max(chords.length, this.barlinesValue ? 1 : 2) * spacing, formatter.preCalculateMinTotalWidth(voices) * 1.25, symbolsWidth)

    return { chords, voices, formatter, symbols, width: minimum + NOTE_END_GAP }
  }

  noteFor(keys, clef, duration, accidentals) {
    if (keys.length === 0) return new GhostNote({ duration })

    const note = new StaveNote({ keys, clef, duration })
    keys.forEach((key, index) => {
      const accidental = this.accidentalFor(key, accidentals)
      if (accidental) note.addModifier(new Accidental(accidental), index)
    })
    if (duration.endsWith("d")) Dot.buildAndAttach([note], { all: true })
    return note
  }

  // An accidental lasts until the barline, so it's written only when the
  // note differs from the last one on that line or space in the bar, and a
  // natural cancels an earlier sharp or flat.
  accidentalFor(key, accidentals) {
    const [name, octave] = key.split("/")
    const position = `${name[0]}/${octave}`
    const accidental = name.slice(1)
    const previous = accidentals.get(position) || ""

    accidentals.set(position, accidental)
    if (accidental === previous) return null
    return accidental || "n"
  }

  // The width of a bar's stave beyond its notes: the clef on the first bar
  // of a line, and padding at either end.
  staveChrome(clefs, first) {
    const staves = clefs.map((clef) => this.staveFor(clef, 0, 0, first))
    Stave.formatBegModifiers(staves)
    return Math.max(...staves.map((stave) => stave.getNoteStartX())) + Stave.rightPadding
  }

  staveFor(clef, x, y, first) {
    const stave = new Stave(x, y, 500)
    stave.setDefaultLedgerLineStyle({ strokeStyle: "currentColor", lineWidth: 1.6 }) // VexFlow's grey vanishes in dark mode
    return first ? stave.addClef(clef) : stave.setBegBarType(BarlineType.NONE)
  }

  drawLine(context, line, clefs, top, stretch, last) {
    let x = 0
    let symbolY = Infinity
    const symbols = []

    line.forEach((measure, i) => {
      const noteWidth = measure.width * (1 + stretch)
      const final = last && i === line.length - 1 && this.barlinesValue
      const staves = clefs.map((clef, s) => {
        const stave = this.staveFor(clef, x, top + s * STAVE_GAP, i === 0)
        if (final) stave.setEndBarType(BarlineType.END)
        return stave
      })
      Stave.formatBegModifiers(staves)

      const start = Math.max(...staves.map((stave) => stave.getNoteStartX())) - x
      staves.forEach((stave) => stave.setWidth(start + noteWidth + Stave.rightPadding).setNoteStartX(x + start).setContext(context).draw())

      measure.formatter.format(measure.voices, noteWidth - NOTE_END_GAP)
      measure.voices.forEach((voice, s) => voice.draw(context, staves[s]))

      if (staves.length > 1) {
        const types = [final ? "boldDoubleRight" : "singleRight"]
        if (i === 0) types.push("brace", "singleLeft")
        types.forEach((type) => new StaveConnector(staves[0], staves[1]).setType(type).setContext(context).draw())
      }

      const notes = measure.voices[0].getTickables()
      measure.symbols.forEach((symbol, n) => {
        if (symbol) symbols.push({ symbol, x: notes[n].getAbsoluteX() - 2 })
      })
      symbolY = Math.min(symbolY, staves[0].getYForLine(-1.5), ...notes.map((note) => topOf(note) - SYMBOL_GAP))

      x += staves[0].getWidth()
    })

    context.save()
    context.setFont(SYMBOL_FONT.family, SYMBOL_FONT.size, SYMBOL_FONT.weight)
    symbols.forEach(({ symbol, x }) => context.fillText(symbol, x, symbolY))
    context.restore()
  }

  // Stacks the lines of music one under another, each as close to the last
  // as its ink allows, and frames the drawing around them.
  stack(svg, groups) {
    const bounds = groups.map((group) => inkBounds(group))
    if (bounds.some((box) => !box)) return // Not laid out (e.g. hidden); keep VexFlow's own sizing.

    let y = 0
    groups.forEach((group, i) => {
      group.setAttribute("transform", `translate(0 ${y - bounds[i].top})`)
      y += bounds[i].bottom - bounds[i].top + SYSTEM_GAP
    })

    const left = Math.floor(Math.min(...bounds.map((box) => box.left))) - PADDING
    const right = Math.ceil(Math.max(...bounds.map((box) => box.right))) + PADDING
    const width = right - left
    const height = Math.ceil(y - SYSTEM_GAP) + PADDING * 2

    svg.setAttribute("viewBox", `${left} ${-PADDING} ${width} ${height}`)
    svg.setAttribute("role", "img")
    svg.setAttribute("aria-label", this.description)
    svg.removeAttribute("width")
    svg.removeAttribute("height")
    svg.removeAttribute("style")
    svg.style.setProperty("--staff-width", `${width}px`)
    this.element.style.removeProperty("width")
  }

  get description() {
    const names = this.chordsValue.map((chord) => {
      const normal = this.normalize(chord)
      const notes = [...normal.bass, ...normal.treble].map((key) => key.split("/")[0]).join(" ")
      return normal.symbol ? `${normal.symbol} (${notes})` : notes
    })
    return `Staff notation: ${names.join(", ")}`
  }
}

function octaveOf(key) {
  return parseInt(key.split("/")[1], 10)
}

// The highest point of a note: its stem when the stem goes up, otherwise its top notehead.
function topOf(note) {
  if (!(note instanceof StaveNote)) return Infinity

  const head = Math.min(...note.getYs()) - 5
  return note.hasStem() && note.getStemDirection() > 0 ? Math.min(head, note.getStemExtents().topY) : head
}

// Chord symbols with real sharp and flat signs: Bbm7b5 becomes B♭m7♭5.
function formatSymbol(symbol) {
  return symbol.replace(/^([A-G])b/, "$1♭").replace(/b(?=\d)/g, "♭").replace(/#/g, "♯")
}

function textWidth(text) {
  const context = textWidth.context ||= document.createElement("canvas").getContext("2d")
  context.font = `${SYMBOL_FONT.weight} ${SYMBOL_FONT.size}px ${SYMBOL_FONT.family}`
  return context.measureText(text).width
}

// The area actually inked by an engraving. getBBox() on a music glyph returns
// the font's whole em box (several staves tall in Bravura), so glyphs are
// measured with canvas text metrics and combined with the drawn shapes.
function inkBounds(element) {
  const bounds = { left: Infinity, top: Infinity, right: -Infinity, bottom: -Infinity }
  const include = (left, top, right, bottom) => {
    bounds.left = Math.min(bounds.left, left)
    bounds.top = Math.min(bounds.top, top)
    bounds.right = Math.max(bounds.right, right)
    bounds.bottom = Math.max(bounds.bottom, bottom)
  }

  element.querySelectorAll("path, rect").forEach((shape) => {
    const box = shape.getBBox()
    if (box.width || box.height) include(box.x, box.y, box.x + box.width, box.y + box.height)
  })

  const metrics = inkBounds.context ||= document.createElement("canvas").getContext("2d")
  element.querySelectorAll("text").forEach((text) => {
    const style = getComputedStyle(text)
    metrics.font = `${style.fontStyle} ${style.fontWeight} ${style.fontSize} ${style.fontFamily}`
    const ink = metrics.measureText(text.textContent)
    const x = parseFloat(text.getAttribute("x"))
    const y = parseFloat(text.getAttribute("y"))
    include(x - ink.actualBoundingBoxLeft, y - ink.actualBoundingBoxAscent, x + ink.actualBoundingBoxRight, y + ink.actualBoundingBoxDescent)
  })

  return bounds.right > bounds.left ? bounds : null
}
