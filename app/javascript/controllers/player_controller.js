import { Controller } from "@hotwired/stimulus"
import { Sequencer, claim, release, running, start } from "audio"

// How fast single notes go: eighth notes at this tempo.
const NOTE_TEMPO = 100
const SETTINGS = "jazzity.player"
// How long after leaving a page that was playing the next one picks up the
// music, as when the voicings or the key change mid-chorus.
const RESUME_WITHIN = 5000

let resume = null

// Plays what's on the page through the electric piano in audio.js.
//
//   <section data-controller="player" data-player-kind-value="sequence"
//            data-player-chords-value='[{"left": [38], "right": [60, 64, 65, 69], "names": [...], "beats": 4}]'>
//
// Chords give the MIDI notes for each hand (see VoicedChord#to_playback).
// A "chord" player sounds them together, or one by one from its arpeggio
// button; a "scale" player runs up its notes and back down; a "sequence"
// player plays its chords in time, a bar of `beats-per-bar` beats at a time,
// with a tempo, a loop, a count-in and, given `next-key-url`, a practice
// mode that goes on to that key after each time through. A player that
// isn't `loopable` plays its sequence once whatever the loop setting.
//
// While a sequence plays, the player marks the sounding chord on its staff
// (see StaffController#highlight), its lead-sheet cells (whose
// data-indices list the chords they stand for) and its keyboard.
export default class extends Controller {
  static targets = ["toggle", "arpeggio", "tempo", "tempoOutput", "loop", "countIn", "nextKey", "staff", "keyboard", "cell"]
  static values = {
    kind: { type: String, default: "chord" },
    chords: Array,
    beatsPerBar: { type: Number, default: 4 },
    shortcut: Boolean,
    loopable: { type: Boolean, default: true },
    nextKeyUrl: String,
    resumeKey: String
  }

  connect() {
    this.playing = null
    this.settings = { tempo: 120, loop: true, countIn: false, ...loadSettings() }
    this.nextKey = false

    this.suspend = this.suspend.bind(this)
    document.addEventListener("turbo:before-cache", this.suspend)
    if (this.shortcutValue) {
      this.shortcut = this.shortcut.bind(this)
      document.addEventListener("keydown", this.shortcut)
    }

    this.update()
    this.resumeIfAsked()
  }

  disconnect() {
    this.suspend()
    document.removeEventListener("turbo:before-cache", this.suspend)
    if (this.shortcutValue) document.removeEventListener("keydown", this.shortcut)
  }

  // Leaving the page: stop, and let the next page carry on if it plays the same music.
  suspend() {
    if (this.playing === "sequence" && this.resumeKeyValue) resume = { key: this.resumeKeyValue, at: Date.now(), nextKey: this.nextKey }
    this.stop()
  }

  resumeIfAsked() {
    if (this.kindValue !== "sequence" || !resume || resume.key !== this.resumeKeyValue) return
    const { at, nextKey } = resume
    resume = null
    if (Date.now() - at > RESUME_WITHIN || !running()) return

    this.nextKey = nextKey && this.hasNextKeyUrlValue
    if (this.nextKey) this.settings.loop = true
    this.play("sequence")
  }

  toggle() {
    this.playing ? this.stop() : this.play(this.kindValue)
  }

  arpeggiate() {
    this.playing === "arpeggio" ? this.stop() : this.play("arpeggio")
  }

  async play(mode) {
    this.stop()
    const attempt = (this.attempt = {})
    this.playing = mode
    this.update()

    await start()
    if (this.attempt !== attempt) return // Stopped, or played again, while audio started.
    claim(this)

    this.sequencer = new Sequencer(this.stepsFor(mode), {
      tempo: () => (mode === "sequence" ? this.tempo : NOTE_TEMPO),
      loop: () => mode === "sequence" && this.loopableValue && this.settings.loop && !this.nextKey,
      countIn: mode === "sequence" && this.hasCountInTarget && this.settings.countIn ? this.beatsPerBarValue : 0,
      onStep: (step) => this.sounding(step),
      onEnd: () => this.ended()
    })
    this.sequencer.start()
    this.update()
  }

  stop() {
    this.attempt = null
    if (!this.playing) return

    this.sequencer?.stop()
    this.sequencer = null
    this.playing = null
    release(this)
    this.mark(null)
    this.update()
  }

  ended() {
    if (this.playing === "sequence" && this.nextKey && this.hasNextKeyUrlValue) {
      this.suspend()
      window.Turbo ? window.Turbo.visit(this.nextKeyUrlValue) : window.location.assign(this.nextKeyUrlValue)
    } else {
      this.stop()
    }
  }

  // The notes to play, as steps for the sequencer.
  stepsFor(mode) {
    const chords = this.chordsValue
    const notes = chords.flatMap((chord) => [...(chord.left || []), ...(chord.right || [])])

    switch (mode) {
      case "chord":
        return [{ notes, beats: 4, hold: 4, spread: 0.008 }]
      case "arpeggio":
        return notes.map((midi, i) => ({ notes: [midi], beats: i === notes.length - 1 ? 3 : 0.5, hold: (notes.length - 1 - i) * 0.5 + 3 }))
      case "scale": {
        const up = [...notes, notes[0] + 12]
        const run = [...up, ...up.slice(0, -1).reverse()]
        return run.map((midi, i) => ({ notes: [midi], beats: i === run.length - 1 ? 2 : 0.5, hold: i === run.length - 1 ? 2 : 0.55 }))
      }
      default:
        return this.barsOf(chords)
    }
  }

  // Each chord for as many beats as it lasts, struck again at each barline
  // it runs over, as the staff writes it.
  barsOf(chords) {
    const perBar = this.beatsPerBarValue
    const steps = []
    let filled = 0

    chords.forEach((chord, index) => {
      let remaining = chord.beats || perBar
      while (remaining > 0) {
        const beats = Math.min(remaining, perBar - filled)
        steps.push({ notes: [...(chord.left || []), ...(chord.right || [])], beats, chord, index })
        remaining -= beats
        filled = (filled + beats) % perBar
      }
    })
    return steps
  }

  sounding(step) {
    if (this.playing === "sequence") this.mark(step.index)
    else this.keyboard?.sound(step.notes)
  }

  // Marks the chord at `index` on the staff, lead sheet and keyboard, or
  // clears the marks for null.
  mark(index) {
    const chord = this.chordsValue[index]

    this.staffTargets.forEach((element) => this.application.getControllerForElementAndIdentifier(element, "staff")?.highlight(index))
    this.cellTargets.forEach((cell) => {
      const current = index !== null && cell.dataset.indices.split(" ").map(Number).includes(index)
      cell.classList.toggle("is-current", current)
    })

    const keyboard = this.keyboard
    if (!keyboard) return
    if (chord) keyboard.show(chord)
    else keyboard.reset()
  }

  get keyboard() {
    return this.hasKeyboardTarget ? this.application.getControllerForElementAndIdentifier(this.keyboardTarget, "keyboard") : null
  }

  // The tempo set on the page's transport; a player without one keeps to a steady 120.
  get tempo() {
    return this.hasTempoTarget ? this.settings.tempo : 120
  }

  // Controls

  retempo() {
    this.settings.tempo = Number(this.tempoTarget.value)
    this.saveSettings()
  }

  toggleLoop() {
    this.settings.loop = !this.settings.loop
    if (!this.settings.loop) this.nextKey = false
    this.saveSettings()
  }

  toggleCountIn() {
    this.settings.countIn = !this.settings.countIn
    this.saveSettings()
  }

  toggleNextKey() {
    this.nextKey = !this.nextKey
    if (this.nextKey) this.settings.loop = true
    this.saveSettings()
  }

  // Space plays and stops the page's main player, unless focus is on
  // something Space already works (a field, a button or a link).
  shortcut(event) {
    if (event.key !== " " || event.repeat || event.metaKey || event.ctrlKey || event.altKey) return
    if (event.target.closest?.("input, textarea, select, button, a, summary, [contenteditable]")) return

    event.preventDefault()
    this.toggle()
  }

  saveSettings() {
    try {
      localStorage.setItem(SETTINGS, JSON.stringify(this.settings))
    } catch {
      // Storage is unavailable; the settings last as long as the page.
    }
    this.update()
  }

  update() {
    this.toggleTargets.forEach((button) => button.setAttribute("aria-pressed", String(!!this.playing && this.playing !== "arpeggio")))
    this.arpeggioTargets.forEach((button) => button.setAttribute("aria-pressed", String(this.playing === "arpeggio")))
    this.loopTargets.forEach((button) => button.setAttribute("aria-pressed", String(this.settings.loop)))
    this.countInTargets.forEach((button) => button.setAttribute("aria-pressed", String(this.settings.countIn)))
    this.nextKeyTargets.forEach((button) => button.setAttribute("aria-pressed", String(this.nextKey)))
    this.tempoTargets.forEach((input) => (input.value = this.settings.tempo))
    this.tempoOutputTargets.forEach((output) => (output.textContent = this.settings.tempo))
  }
}

function loadSettings() {
  try {
    return JSON.parse(localStorage.getItem(SETTINGS)) || {}
  } catch {
    return {}
  }
}
