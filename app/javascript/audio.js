// A small electric piano built from Web Audio oscillators, and a sequencer
// that plays chords on it in time.
//
// Each note is a little FM synthesizer, after the Rhodes patches of the
// classic FM keyboards: a sine wave whose pitch is modulated by a second
// sine at the same frequency (the "bark" of a struck tine, bright at first
// and mellowing as the note sounds) and, for an instant at the attack, by
// a third at fourteen times the frequency, the metallic ping of the tine.
// Low notes ring longer than high ones, notes are spread across the stereo
// field like the keys of a piano, and everything goes through a gentle
// filter, a compressor (so a six-note chord can't clip) and a touch of
// synthesized room reverb.
//
// Browsers only let audio start from a user gesture, so call `start()` from
// a click or key handler before playing anything.

const LOOKAHEAD = 0.15 // Seconds of music scheduled ahead of the clock
const TICK = 25 // Milliseconds between scheduling passes

let context = null
let output = null
let owner = null
const voices = new Set()

function audioContext() {
  if (context) return context

  // iOS plays Web Audio as a ringer sound, silenced by the phone's silent
  // switch, unless the page says it's playing media.
  if (navigator.audioSession) navigator.audioSession.type = "playback"

  const AudioContext = window.AudioContext || window.webkitAudioContext
  context = new AudioContext({ latencyHint: "interactive" })

  const compressor = context.createDynamicsCompressor()
  compressor.threshold.value = -20
  compressor.knee.value = 12
  compressor.ratio.value = 4
  compressor.attack.value = 0.004
  compressor.release.value = 0.2
  compressor.connect(context.destination)

  const tone = context.createBiquadFilter()
  tone.type = "lowpass"
  tone.frequency.value = 5500
  tone.Q.value = 0.4
  tone.connect(compressor)

  const reverb = context.createConvolver()
  reverb.buffer = roomImpulse(context, 1.6)
  const wet = context.createGain()
  wet.gain.value = 0.18
  reverb.connect(wet).connect(compressor)

  output = context.createGain()
  output.gain.value = 0.8
  output.connect(tone)
  output.connect(reverb)

  return context
}

// Decaying stereo noise: a cheap stand-in for the sound of a small room.
function roomImpulse(context, seconds) {
  const length = Math.floor(context.sampleRate * seconds)
  const buffer = context.createBuffer(2, length, context.sampleRate)
  for (let channel = 0; channel < 2; channel++) {
    const data = buffer.getChannelData(channel)
    for (let i = 0; i < length; i++) data[i] = (Math.random() * 2 - 1) * (1 - i / length) ** 3
  }
  return buffer
}

// Starts (or resumes) audio. Call from a user gesture.
export async function start() {
  const context = audioContext()
  if (context.state !== "running") await context.resume()
  return context
}

// Whether audio is already allowed to play, so playback can carry on from
// one page to the next without another gesture.
export function running() {
  return context?.state === "running"
}

export function now() {
  return context ? context.currentTime : 0
}

// Makes `player` the one thing sounding, stopping whatever played before.
// Players have a `stop()` method.
export function claim(player) {
  if (owner && owner !== player) owner.stop()
  owner = player
}

export function release(player) {
  if (owner === player) owner = null
}

export function frequency(midi) {
  return 440 * 2 ** ((midi - 69) / 12)
}

// Sounds a MIDI note at an audio time for a number of seconds.
export function playNote(midi, when, duration, velocity = 0.75) {
  const context = audioContext()
  const pitch = frequency(midi)
  const end = when + duration
  const decay = Math.min(2.4, Math.max(0.6, 2.4 - (midi - 36) * 0.035))

  const amp = context.createGain()
  amp.gain.setValueAtTime(0, when)
  amp.gain.linearRampToValueAtTime(0.2 * velocity, when + 0.006)
  amp.gain.setTargetAtTime(0.045 * velocity, when + 0.006, decay)
  amp.gain.setTargetAtTime(0, end, 0.07)

  const pan = context.createStereoPanner()
  pan.pan.value = Math.max(-0.4, Math.min(0.4, (midi - 60) / 40))
  amp.connect(pan).connect(output)

  const carrier = context.createOscillator()
  carrier.frequency.value = pitch

  const bark = context.createOscillator()
  bark.frequency.value = pitch
  const barkDepth = context.createGain()
  barkDepth.gain.setValueAtTime(pitch * (0.6 + 1.4 * velocity), when)
  barkDepth.gain.setTargetAtTime(pitch * 0.25, when, 0.25)
  bark.connect(barkDepth).connect(carrier.frequency)

  const tine = context.createOscillator()
  tine.frequency.value = Math.min(pitch * 14, 18000)
  const tineDepth = context.createGain()
  tineDepth.gain.setValueAtTime(pitch * 1.2 * velocity, when)
  tineDepth.gain.setTargetAtTime(0, when, 0.012)
  tine.connect(tineDepth).connect(carrier.frequency)

  carrier.connect(amp)

  const oscillators = [carrier, bark, tine]
  const voice = { amp, oscillators, end }
  oscillators.forEach((oscillator) => {
    oscillator.start(when)
    oscillator.stop(end + 0.6)
  })
  carrier.onended = () => voices.delete(voice)
  voices.add(voice)

  log({ type: "note", midi, when, duration })
}

// A woodblock-like tick for counting in, higher on the first beat.
export function playClick(when, accent = false) {
  const context = audioContext()
  const oscillator = context.createOscillator()
  oscillator.type = "triangle"
  oscillator.frequency.value = accent ? 1760 : 1320

  const amp = context.createGain()
  amp.gain.setValueAtTime(0, when)
  amp.gain.linearRampToValueAtTime(accent ? 0.3 : 0.2, when + 0.002)
  amp.gain.setTargetAtTime(0, when + 0.002, 0.018)
  oscillator.connect(amp).connect(output)

  oscillator.start(when)
  oscillator.stop(when + 0.15)
  const voice = { amp, oscillators: [oscillator], end: when + 0.15 }
  oscillator.onended = () => voices.delete(voice)
  voices.add(voice)

  log({ type: "click", when, accent })
}

// Silences everything, scheduled or sounding, with a quick fade.
export function silence() {
  if (!context) return

  const time = context.currentTime
  voices.forEach(({ amp, oscillators }) => {
    amp.gain.cancelScheduledValues(time)
    amp.gain.setValueAtTime(amp.gain.value, time)
    amp.gain.setTargetAtTime(0, time, 0.015)
    oscillators.forEach((oscillator) => {
      try {
        oscillator.stop(time + 0.1)
      } catch {
        // Already stopped.
      }
    })
  })
  voices.clear()
}

// Records what was scheduled when a page (or a test) asks, by setting
// window.jazzityAudioLog to an array.
function log(event) {
  if (Array.isArray(window.jazzityAudioLog)) window.jazzityAudioLog.push(event)
}

// Plays steps one after another at a tempo, looking a little ahead of the
// audio clock so the timing stays steady whatever the page is doing.
//
// Each step is {notes, beats, hold, spread}: MIDI notes struck together (or
// `spread` seconds apart), lasting `beats` beats and sounding for `hold`
// beats (just under `beats` by default). `tempo()` and `loop()` are read
// as the music goes, so they can change while it plays. `onStep(step, i)`
// is called as each step sounds and `onEnd()` once the last step has
// finished without looping.
export class Sequencer {
  constructor(steps, { tempo = () => 120, loop = () => false, countIn = 0, onStep = () => {}, onEnd = () => {} } = {}) {
    this.steps = steps
    this.tempo = tempo
    this.loop = loop
    this.countIn = countIn
    this.onStep = onStep
    this.onEnd = onEnd
    this.timeouts = new Set()
  }

  start() {
    const context = audioContext()
    this.index = 0
    this.finished = false
    this.time = context.currentTime + 0.06

    const beat = 60 / this.tempo()
    for (let i = 0; i < this.countIn; i++) playClick(this.time + i * beat, i === 0)
    this.time += this.countIn * beat

    this.timer = setInterval(() => this.schedule(), TICK)
    this.schedule()
  }

  schedule() {
    const horizon = audioContext().currentTime + LOOKAHEAD

    while (this.time < horizon) {
      if (this.index >= this.steps.length) {
        if (this.steps.length === 0 || !this.loop()) return this.finish()
        this.index = 0
      }

      const step = this.steps[this.index]
      const beat = 60 / this.tempo()
      const hold = (step.hold ?? step.beats * 0.96) * beat
      step.notes.forEach((midi, i) => playNote(midi, this.time + i * (step.spread || 0), hold - i * (step.spread || 0), step.velocity))

      const index = this.index
      this.cue(this.time, () => this.onStep(step, index))
      this.time += step.beats * beat
      this.index += 1
    }
  }

  finish() {
    clearInterval(this.timer)
    if (this.finished) return
    this.finished = true
    this.cue(this.time, () => this.onEnd())
  }

  // Runs a callback when the music reaches an audio time.
  cue(time, callback) {
    const context = audioContext()
    const latency = context.outputLatency || context.baseLatency || 0
    const timeout = setTimeout(() => {
      this.timeouts.delete(timeout)
      callback()
    }, Math.max(0, (time - context.currentTime + latency) * 1000))
    this.timeouts.add(timeout)
  }

  stop() {
    clearInterval(this.timer)
    this.timeouts.forEach((timeout) => clearTimeout(timeout))
    this.timeouts.clear()
    silence()
  }
}
