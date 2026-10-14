# A note at a definite pitch: a key, which gives its spelling, and a MIDI
# note number, which gives its sound (60 is middle C). Written for the staff
# as "Eb/4". Cb and B# take the octave of their letter, so Cb4 sounds as B3
# (MIDI 59) and B#3 as C4 (MIDI 60).
class Pitch
  include Comparable

  attr_reader :key, :midi

  def initialize(key, midi)
    @key = key.is_a?(Key) ? key : Key[key]
    @midi = midi
  end

  # The lowest pitch of the key at or above a MIDI note.
  def self.at_or_above(key, midi)
    new(key, midi + (key.index - midi) % 12)
  end

  # The pitch of the key nearest a MIDI note, the lower when two are as near.
  def self.nearest(key, midi)
    below = midi - (midi - key.index) % 12
    midi - below <= below + 12 - midi ? new(key, below) : new(key, below + 12)
  end

  def octave
    midi.div(12) - 1 + key.octave_offset
  end

  def octaves(count)
    self.class.new(key, midi + count * 12)
  end

  def <=>(other)
    midi <=> other.midi
  end

  def ==(other)
    other.is_a?(Pitch) && midi == other.midi && key == other.key
  end

  def to_s
    "#{key.name}/#{octave}"
  end

  def as_json(_options = nil)
    to_s
  end
end
