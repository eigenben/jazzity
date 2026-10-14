# Voices a run of chords the way a pianist would: every chord from one
# voicing family, each voicing placed in a comfortable register, and the
# voicings and octaves chosen so the voices move as little as possible from
# one chord to the next.
#
#   VoiceLeader.new(progression.chords, family: VoicingFamily["Guide Tones"]).voiced_chords
#
# The candidates for each chord are its voicings in the family (or in the
# nearest family that has the chord, see FALLBACKS) at every octave where
# they fit the register. A dynamic program over the sequence then picks the
# candidates with the lowest total cost: the semitones each voice moves, plus
# penalties for leaps in the top voice and for straying from the middle of
# the register. Ties go to the earlier voicing and the lower octave, so the
# same chords always get the same voicings.
class VoiceLeader
  # A range of MIDI notes for a voicing and the pitch it should centre on.
  Register = Data.define(:low, :high, :centre) do
    def fits?(pitches)
      overshoot(pitches).zero?
    end

    def overshoot(pitches)
      [low - pitches.first.midi, 0].max + [pitches.last.midi - high, 0].max
    end

    def octaves(pitch_class)
      (low..high).select { |midi| midi % 12 == pitch_class }
    end
  end

  # Rootless voicings are written for the right hand over the root in the
  # left, from A3 to E5 and centred on F4. That is the left-hand rootless
  # register (about D3 to A4) moved up a 4th, so the voicing sits on the
  # treble staff with at most two ledger lines instead of straddling middle C.
  RIGHT_HAND = Register.new(low: 57, high: 76, centre: 65)

  # Voicings that include the root are played by the left hand alone, from
  # E2 to E4. How low they can go depends on their intervals, see
  # LOWER_INTERVAL_LIMITS.
  LEFT_HAND = Register.new(low: 40, high: 64, centre: 52)

  # The root under a right-hand voicing, C2 to D3.
  BASS = Register.new(low: 36, high: 50, centre: 43)

  # The lowest MIDI note an interval (in semitones) can start on before it
  # sounds muddy: a major 3rd no lower than Bb2, a 7th no lower than F2.
  LOWER_INTERVAL_LIMITS = {
    1 => 52, 2 => 51, 3 => 48, 4 => 46, 5 => 45, 6 => 47, 7 => 34,
    8 => 43, 9 => 41, 10 => 41, 11 => 41, 12 => 34, 13 => 40, 14 => 39
  }.freeze

  # Cost of moving the top voice, per semitone beyond a whole step.
  TOP_LEAP_WEIGHT = 1.0
  # Cost of the average pitch of a voicing straying from the register's centre, per semitone.
  DRIFT_WEIGHT = 0.5

  DEFAULT_FAMILY = "4-Note Rootless (Type I/II)"

  # For each family, the families to voice a chord from when it has no
  # voicings in that family (triads and sus4 chords, say): rootless families
  # fall back on other rootless families before rooted ones, and vice versa.
  FALLBACKS = {
    "4-Note Rootless (Type I/II)" => ["Rootless 3-Note Shells", "Guide Tones", "4-Note Rooted", "Rooted Guide Tones", "Triads"],
    "Rootless 3-Note Shells" => ["4-Note Rootless (Type I/II)", "Guide Tones", "Rooted Guide Tones", "4-Note Rooted", "Triads"],
    "Guide Tones" => ["Rootless 3-Note Shells", "4-Note Rootless (Type I/II)", "Rooted Guide Tones", "4-Note Rooted", "Triads"],
    "Rooted Guide Tones" => ["4-Note Rooted", "Triads", "Guide Tones", "Rootless 3-Note Shells", "4-Note Rootless (Type I/II)"],
    "4-Note Rooted" => ["Rooted Guide Tones", "Triads", "4-Note Rootless (Type I/II)", "Rootless 3-Note Shells", "Guide Tones"],
    "Triads" => ["4-Note Rooted", "Rooted Guide Tones", "4-Note Rootless (Type I/II)", "Rootless 3-Note Shells", "Guide Tones"]
  }.freeze

  # One way to play a chord: a voicing (nil for the chord's own tones) at
  # definite pitches, played over a separate root or not.
  Candidate = Data.define(:voicing, :pitches, :over_root) do
    def top
      pitches.last.midi
    end

    def mean
      pitches.sum(&:midi) / pitches.size.to_f
    end
  end

  attr_reader :chords, :family, :overrides

  # `overrides` maps a chord's position (as an integer or string) to the
  # voicing, or voicing id, to use for it. Positions without one, and ids
  # that aren't voicings of that chord, are voice-led.
  def initialize(chords, family: nil, overrides: {})
    @chords = chords.to_a
    @family = family || self.class.default_family
    @overrides = overrides.to_h.transform_keys(&:to_s)
  end

  def self.default_family
    VoicingFamily.find_by(name: DEFAULT_FAMILY)
  end

  def voiced_chords
    @voiced_chords ||= begin
      choices = best_path(chords.each_with_index.map { |chord, i| candidates_for(chord, i) })
      previous_root = nil

      chords.zip(choices).map do |chord, choice|
        root = (bass_root(chord, previous_root) if choice.over_root)
        previous_root = root if root
        VoicedChord.new(chord: chord, voicing: choice.voicing, pitches: choice.pitches, root: root)
      end
    end
  end

  # The voicings a chord can be played with, in order of preference.
  def voicings_for(chord, position = nil)
    if (override = override_for(chord, position))
      return [override]
    end

    by_family = chord.voicings.includes(:voicing_family).sort_by(&:id).group_by(&:voicing_family)
    families = family ? [family.name, *FALLBACKS.fetch(family.name) { [DEFAULT_FAMILY, *FALLBACKS[DEFAULT_FAMILY]] }] : []
    chosen = families.lazy.map { |name| by_family.find { |f, _| f.name == name }&.last }.find(&:itself)

    chosen || by_family.values.first || []
  end

  private

  def override_for(chord, position)
    choice = overrides[position.to_s] unless position.nil?
    return choice if choice.is_a?(Voicing)

    chord.voicings.find { |voicing| voicing.id == choice.to_i } if choice.to_i.positive?
  end

  def candidates_for(chord, position)
    key = chord.key || Key.default
    voicings = voicings_for(chord, position)
    sources = voicings.any? ? voicings.map { |v| [v, v.tones.in_key_of(key)] } : [[nil, chord.tones.in_key_of(key)]]

    candidates = sources.flat_map do |voicing, tones|
      over_root = played_over_root?(voicing)
      register = over_root ? RIGHT_HAND : LEFT_HAND
      placements(tones, register).map { |pitches| Candidate.new(voicing, pitches, over_root) }
    end

    candidates.select { |c| fits?(c) }.presence || closest_fits(candidates)
  end

  # Every octave of the voicing whose bottom note lies in (or near) the register.
  def placements(tones, register)
    first = tones.keys.first
    (register.low - 12..register.high).select { |midi| midi % 12 == first.index }.map { |midi| tones.pitches(midi) }
  end

  def played_over_root?(voicing)
    voicing&.voicing_family&.rootless? || family&.rootless? || false
  end

  def register_for(candidate)
    candidate.over_root ? RIGHT_HAND : LEFT_HAND
  end

  def fits?(candidate)
    register_for(candidate).fits?(candidate.pitches) && (candidate.over_root || above_interval_limits?(candidate.pitches))
  end

  def above_interval_limits?(pitches)
    pitches.each_cons(2).all? do |lower, upper|
      lower.midi >= LOWER_INTERVAL_LIMITS.fetch(upper.midi - lower.midi, 0)
    end
  end

  # When no octave of any voicing fits (a two-handed upper structure is too
  # wide for one hand's register), take those that overshoot it least.
  def closest_fits(candidates)
    least = candidates.map { |c| register_for(c).overshoot(c.pitches) }.min
    candidates.select { |c| register_for(c).overshoot(c.pitches) == least }
  end

  def cost(candidate)
    (candidate.mean - register_for(candidate).centre).abs * DRIFT_WEIGHT
  end

  def transition_cost(from, to)
    movement(from.pitches.map(&:midi), to.pitches.map(&:midi)) +
      [(from.top - to.top).abs - 2, 0].max * TOP_LEAP_WEIGHT
  end

  # The semitones the voices move: note for note when the voicings have the
  # same number of notes, otherwise each note to the nearest note of the other.
  def movement(from, to)
    if from.size == to.size
      from.zip(to).sum { |a, b| (a - b).abs }
    else
      nearest = ->(notes, others) { notes.sum { |n| others.map { |o| (n - o).abs }.min } }
      (nearest.call(from, to) + nearest.call(to, from)) / 2.0
    end
  end

  def best_path(options)
    return [] if options.empty?

    totals = options.first.map { |candidate| cost(candidate) }
    links = [Array.new(totals.size)]

    options.each_cons(2) do |previous, current|
      steps = current.map do |candidate|
        from = previous.each_index.min_by { |i| totals[i] + transition_cost(previous[i], candidate) }
        [totals[from] + transition_cost(previous[from], candidate) + cost(candidate), from]
      end
      totals = steps.map(&:first)
      links << steps.map(&:last)
    end

    index = totals.each_index.min_by { |i| totals[i] }
    options.each_index.reverse_each.map do |step|
      options[step][index].tap { index = links[step][index] }
    end.reverse
  end

  # The root an octave or so below the voicing, as near as possible to the
  # previous root so the bass line moves smoothly.
  def bass_root(chord, previous)
    root = chord.key || Key.default
    target = previous&.midi || BASS.centre
    BASS.octaves(root.index).map { |midi| Pitch.new(root, midi) }.min_by { |pitch| [(pitch.midi - target).abs, pitch.midi] }
  end
end
