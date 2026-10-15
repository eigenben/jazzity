require "set"

class NoteSequence
  include Routable
  include Enumerable
  include KeyContext

  # The most notes a sequence can have.
  MAX_NOTES = 48

  attr_accessor :keys
  attr_accessor :invalid_keys

  def initialize(value = [])
    @value_as_given = value
    @keys = []
    @invalid_keys = []

    value = value.split.reject(&:empty?) if value.instance_of?(String)
    value.each do |key_name|
      key_object = key_name.is_a?(Key) ? key_name : Key.parse(key_name)

      if key_object.nil?
        @invalid_keys << key_name
      else
        @keys << key_object
      end
    end
  end

  def to_s
    name
  end

  def name
    keys.join(" ")
  end

  def to_param
    keys.join(" ")
  end

  def title
    name
  end

  # The note the sequence is heard from: its first.
  def home_key
    keys.first
  end

  # The same notes moved so the first is `key`, each spelled from the
  # letter its interval calls for.
  def in_key_of(key)
    key = Key[key] unless key.nil? || key.is_a?(Key)
    return self if key.nil? || keys.empty?

    self.class.new(keys.map { |note| key.shifted((note.index - home_key.index) % 12, (note.letter_index - home_key.letter_index) % 7) }).tap do |sequence|
      sequence.key = key
    end
  end

  def notes
    keys.map(&:name)
  end
  def staff_notes
    octavized_notes.map { |n| [n] }
  end

  def octavized_notes(octave = 4)
    Tones.octavize(keys, octave)
  end

  class << self
    def resolve(value)
      sequence = new(value)
      if sequence.invalid_keys.empty? and sequence.keys.size.between?(1, MAX_NOTES)
        sequence
      else
        nil
      end
    end

    alias_method :[], :resolve
  end

  delegate :each, :to => :keys

  # The chords these notes spell, each rooted on the note as it was written
  # (F# A# C# is F# major, not Gb), a chord on the first note first.
  def chords
    @chords ||= keys.uniq(&:index).flat_map do |root|
      intervals = keys.map { |note| (note.index - root.index) % 12 }.to_set
      Chord.all.select { |chord| chord.tones.map(&:tone).to_set == intervals }.map { |chord| chord.in_key_of(root) }
    end.extend(Chords)
  end

  # The scales that fit those chords, each in the chord's key.
  def modes
    chords.flat_map do |chord|
      chord.chord_scales.map { |chord_scale| chord_scale.mode.in_key_of(chord.key.shifted(chord_scale.offset)) }
    end.uniq { |mode| [mode.id, mode.key.name] }
  end
end
