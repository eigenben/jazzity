# An ordered collection of tones (the degrees of a chord, scale or voicing)
# that can be realized as concrete notes in a key and, for scales, a mode.
#
# Each Tone is stored relative to C: a chromatic offset (tone, 0-11), a
# diatonic letter offset (letter_index, 0-6) used to pick the right spelling
# (D# vs Eb), and its position within the collection. Transposing and
# rotating return new Tones rather than mutating, so the same record can be
# rendered in several keys.
class Tones
  include Enumerable

  attr_reader :key, :mode

  def initialize(tones, key: nil, mode: nil)
    @tones = tones
    @key = key.nil? || key.is_a?(Key) ? key : Key[key]
    @mode = mode
  end

  def in_key_of(key)
    self.class.new(@tones, key: key, mode: mode)
  end

  def in_mode(mode)
    self.class.new(@tones, key: key, mode: mode)
  end

  def each(&block)
    realized.each(&block)
  end

  def keys
    @keys ||= map { |tone| Key.from_index(tone.tone, tone.letter_index) }
  end

  def notes
    keys.map(&:name)
  end

  def octavized_notes(octave = 4)
    return [] if keys.empty?

    octave -= 1 if (8..11).include?(keys.first.index)
    last_index = keys.first.index

    effective_octave = (keys.first.name == "Cb") ? octave + 1 : octave  # Hack for Cb, which is a weird case...

    ["#{notes.first}/#{effective_octave}"] + keys.from(1).map do |key|
      index = key.index > last_index ? key.index : key.index + 12
      octave += 1 if (last_index..index).include?(12)
      last_index = key.index
      effective_octave = (key.name == "Cb") ? octave + 1 : octave  # Hack for Cb, which is a weird case...
      "#{key.name}/#{effective_octave}"
    end
  end

  def intervals
    previous = 0
    keys.map(&:index).map do |index|
      (index - previous).tap { previous = index }
    end[1..-1].map { |i| i % 12 }
  end

  def step_names
    intervals.map { |step| Key::Steps.invert[step] }
  end

  def interval_names
    intervals.map { |step| Key::Intervals.invert[step] }
  end

  private

  def realized
    @realized ||= @tones.map { |tone| realize(tone) }.sort_by(&:position)
  end

  def realize(tone)
    Tone.new(
      :tone => key ? (tone.tone + key.index) % 12 : tone.tone,
      :letter_index => key ? (tone.letter_index + key.letter_index) % 7 : tone.letter_index,
      :position => mode ? (tone.position - mode) % @tones.size + 1 : tone.position
    )
  end
end
