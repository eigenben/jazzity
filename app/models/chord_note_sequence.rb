class ChordNoteSequence
  include Routable
  include Enumerable
  include KeyContext

  attr_accessor :key_groups
  attr_accessor :note_sequences
  attr_accessor :invalid_note_sequences

  def initialize(value = [])
    @value_as_given = value
    @key_groups = []
    @note_sequences = []
    @invalid_note_sequences = []

    value = value.split(/[,|]/).map(&:strip).reject(&:blank?) if value.instance_of?(String)
    value.each do |key_group|
      note_sequence = key_group.is_a?(NoteSequence) ? key_group : NoteSequence[key_group]

      if note_sequence.nil?
        @invalid_note_sequences << key_group
      else
        @note_sequences << note_sequence
        @key_groups << key_group
      end
    end
  end

  def to_s
    name
  end

  def name
    note_sequences.map(&:to_s).join(", ")
  end

  def to_param
    note_sequences.map(&:to_param).join(",")
  end

  def title
    name
  end

  # The key of a known progression the chords make, or else the first note.
  def home_key
    @home_key ||= progressions.first&.key || note_sequences.first&.home_key
  end

  # The same chords moved from their home key to `key`.
  def in_key_of(key)
    key = Key[key] unless key.nil? || key.is_a?(Key)
    return self if key.nil? || note_sequences.empty?

    home = home_key
    moved = note_sequences.map { |notes| notes.in_key_of(key.shifted((notes.home_key.index - home.index) % 12, (notes.home_key.letter_index - home.letter_index) % 7)) }
    self.class.new(moved).tap { |sequence| sequence.key = key }
  end

  def notes
    note_sequences.map(&:notes)
  end
  def octavized_notes
    note_sequences.map(&:octavized_notes)
  end
  def staff_notes
    octavized_notes
  end

  def chords
    note_sequences.map(&:chords)
  end

  class << self
    def resolve(value)
      sequence = new(value)
      if sequence.invalid_note_sequences.empty? and sequence.note_sequences.size > 1
        sequence
      else
        nil
      end
    end

    alias_method :[], :resolve
  end

  delegate :each, :to => :note_sequences

  # Known progressions that some reading of the notes as chords matches,
  # trying at most a few dozen readings.
  def progressions
    readings = chords.reduce([[]]) { |partial, group| partial.product(group).map(&:flatten) }.first(48)
    readings.flat_map { |reading| ChordSequence.new(reading).progressions }.uniq { |progression| [progression.id, progression.key&.name] }
  end
end
