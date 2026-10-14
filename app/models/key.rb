class Key
  include Routable

  attr_reader :name, :long_name, :index, :letter_index, :cycle_index, :primary

  Letters = {'C' => 0, 'D' => 1, 'E' => 2, 'F' => 3, 'G' => 4, 'A' => 5, 'B' => 6}
  Steps = {'H' => 1, 'W' => 2, 'm3' => 3, 'M3' => 4, '4' => 5, '#4' => 6, '5' => 7}

  Intervals = {
    'u' => 0, 'unison' => 0, '0' => 0,
    'b2' => 1, 'b9' => 1, 'min2' => 1, 'S' => 1, 'H' => 1, 'm2' => 1,
    'M2' => 2, '9' => 2, 'maj2' => 2, 'T' => 2, 'W' => 2, '2' => 2,
    'b3' => 3, 'min3' => 3, '#2' => 3, '#9' => 3, 'm3' => 3,
    '3' => 4, 'maj3' => 4, 'M3' => 4,
    "11" => 5,
    'p4' => 5, '4' => 5,
    "#11" => 6,
    'b5' => 6, 'aug4' => 6, 'dim5' => 6, '#4' => 6,
    'p5' => 7, '5' => 7,
    "b13" => 8,
    'b6' => 8, 'aug5' => 8, '#5' => 8,
    "bb7" => 9, "13" => 9,
    'M6' => 9, 'maj6' => 9, '6' => 9,
    'm7' => 10, 'min7' => 10, 'dom7' => 10, 'b7' => 10,
    'maj7' => 11, 'M7' => 11, '7' => 11,
    '8' => 12, 'octave' => 12
  }

  IntervalLetterIndexes = {
    'u' => 0, 'unison' => 0, '0' => 0,
    'b2' => 1, 'b9' => 1, 'min2' => 1, 'S' => 1, 'H' => 1, 'm2' => 1,
    'M2' => 1, '9' => 1, 'maj2' => 1, 'T' => 1, 'W' => 1, '2' => 1,
    'b3' => 2, 'min3' => 2, '#2' => 1, '#9' => 1, 'm3' => 2,
    '3' => 2, 'maj3' => 2, 'M3' => 2,
    "11" => 3,
    'p4' => 3, '4' => 3,
    "#11" => 3,
    'b5' => 4, 'aug4' => 3, 'dim5' => 4, '#4' => 3,
    'p5' => 4, '5' => 4,
    "b13" => 5,
    'b6' => 5, 'aug5' => 4, '#5' => 4,
    "bb7" => 6, "13" => 5,
    'M6' => 5, 'maj6' => 5, '6' => 5,
    'm7' => 6, 'min7' => 6, 'dom7' => 6, 'b7' => 6,
    'maj7' => 6, 'M7' => 6, '7' => 6,
    '8' => 7, 'octave' => 7
  }

  # The number of letters each chromatic offset from a key moves when no
  # scale degree is given. Diatonic degrees take their own letter; the
  # chromatic ones are named the way jazz players usually name them: bII
  # (tritone substitute), bIII, #IV (as in #iv°7), bVI and bVII.
  DegreeLetterOffsets = [0, 1, 1, 2, 2, 3, 3, 4, 5, 5, 6, 6].freeze

  # Semitones from the key to each degree of its major scale.
  MajorScaleSteps = [0, 2, 4, 5, 7, 9, 11].freeze

  def initialize(attributes = {})
    @primary = true

    attributes.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end

  def self.all
    @all ||= [
      Key.new(name: 'C', long_name: 'C', index: 0, letter_index: 0, cycle_index: 0),
      Key.new(name: 'B#', long_name: 'B Sharp', index: 0, letter_index: 6, cycle_index: 0,
              primary: false),
      Key.new(name: 'Dbb', long_name: 'D Double-Flat', index: 0, letter_index: 1, cycle_index: 0,
              primary: false),

      Key.new(name: 'F', long_name: 'F', index: 5, letter_index: 3, cycle_index: 1),
      Key.new(name: 'E#', long_name: 'E Sharp', index: 5, letter_index: 2, cycle_index: 1,
              primary: false),
      Key.new(name: 'Gbb', long_name: 'G Double-Flat', index: 5, letter_index: 4, cycle_index: 1,
              primary: false),

      Key.new(name: 'Bb', long_name: 'B Flat', index: 10, letter_index: 6, cycle_index: 2),
      Key.new(name: 'A#', long_name: 'A Sharp', index: 10, letter_index: 5, cycle_index: 2,
              primary: false),
      Key.new(name: 'Cbb', long_name: 'C Double-Flat', index: 10, letter_index: 0, cycle_index: 2,
              primary: false),

      Key.new(name: 'Eb', long_name: 'E Flat', index: 3, letter_index: 2, cycle_index: 3),
      Key.new(name: 'D#', long_name: 'D Sharp', index: 3, letter_index: 1, cycle_index: 3,
              primary: false),
      Key.new(name: 'Fbb', long_name: 'F Double Flat', index: 3, letter_index: 3, cycle_index: 3,
              primary: false),

      Key.new(name: 'Ab', long_name: 'A Flat', index: 8, letter_index: 5, cycle_index: 4),
      Key.new(name: 'G#', long_name: 'G Sharp', index: 8, letter_index: 4, cycle_index: 4,
              primary: false),

      Key.new(name: 'Db', long_name: 'D Flat', index: 1, letter_index: 1, cycle_index: 5),
      Key.new(name: 'C#', long_name: 'C Sharp', index: 1, letter_index: 0, cycle_index: 5,
              primary: false),
      Key.new(name: 'B##', long_name: 'B Double-Sharp', index: 1, letter_index: 6, cycle_index: 5,
              primary: false),

      Key.new(name: 'Gb', long_name: 'G Flat', index: 6, letter_index: 4, cycle_index: 6),
      Key.new(name: 'F#', long_name: 'F Sharp', index: 6, letter_index: 3, cycle_index: 6,
              primary: false),
      Key.new(name: 'E##', long_name: 'E Double-Sharp', index: 6, letter_index: 2, cycle_index: 6,
              primary: false),

      Key.new(name: 'B', long_name: 'B', index: 11, letter_index: 6, cycle_index: 7),
      Key.new(name: 'Cb', long_name: 'C Flat', index: 11, letter_index: 0, cycle_index: 7,
              primary: false),
      Key.new(name: 'A##', long_name: 'A Double-Sharp', index: 11, letter_index: 5, cycle_index: 7,
              primary: false),

      Key.new(name: 'E', long_name: 'E', index: 4, letter_index: 2, cycle_index: 8),
      Key.new(name: 'Fb', long_name: 'F Flat', index: 4, letter_index: 3, cycle_index: 8,
              primary: false),
      Key.new(name: 'D##', long_name: 'D Double-Sharp', index: 4, letter_index: 1, cycle_index: 8,
              primary: false),

      Key.new(name: 'A', long_name: 'A', index: 9, letter_index: 5, cycle_index: 9),
      Key.new(name: 'Bbb', long_name: 'B Double-Flat', index: 9, letter_index: 6, cycle_index: 9,
              primary: false),
      Key.new(name: 'G##', long_name: 'G Double-Sharp', index: 9, letter_index: 4, cycle_index: 9,
              primary: false),

      Key.new(name: 'D', long_name: 'D', index: 2, letter_index: 1, cycle_index: 10),
      Key.new(name: 'C##', long_name: 'C Double-Sharp', index: 2, letter_index: 0, cycle_index: 10,
              primary: false),
      Key.new(name: 'Ebb', long_name: 'E Double-Flat', index: 2, letter_index: 2, cycle_index: 10,
              primary: false),

      Key.new(name: 'G', long_name: 'G', index: 7, letter_index: 4, cycle_index: 11),
      Key.new(name: 'F##', long_name: 'F Double-Sharp', index: 7, letter_index: 3, cycle_index: 11,
              primary: false),
      Key.new(name: 'Abb', long_name: 'A Double-Flat', index: 7, letter_index: 5, cycle_index: 11,
              primary: false)
    ].freeze
  end

  def self.primaries
    all.select(&:primary)
  end

  # The keys a jazz musician expects to be offered: one per pitch around the
  # cycle of fifths, with F# alongside Gb.
  def self.standard
    primaries.flat_map { |key| key.name == "Gb" ? [key, self["F#"]] : [key] }
  end

  # The standard keys plus C#, which players write as often as Db.
  def self.searchable
    standard + [self["C#"]]
  end

  # The key with the given pitch, spelled with the given letter when one was
  # asked for and can be written with at most two accidentals.
  def self.from_index(value, preferred_letter = nil)
    return unless value.is_a?(Integer)

    value %= 12
    (preferred_letter && all.find { |k| k.index == value && k.letter_index == preferred_letter }) ||
      all.find { |k| k.index == value && k.primary }
  end

  # Like from_index, but never returns a double sharp or double flat: those
  # are respelled with the nearest letter that needs a single accidental
  # (Ebb becomes D, B## becomes C#). Used to name chord roots.
  def self.spelled(value, letter_index)
    key = from_index(value, letter_index)
    return key unless key.double?

    all.select { |k| k.index == key.index && !k.double? }.min_by do |k|
      distance = (k.letter_index - letter_index) % 7
      [[distance, 7 - distance].min, k.primary ? 0 : 1]
    end
  end

  def self.from_name(value)
    all.find { |k| k.name == value }
  end

  def self.[](value)
    from_name(value) || from_index(value)
  end

  # A key typed by hand: a letter in either case with sharps or flats
  # written # and b or ♯ and ♭, as in "f#", "Bb", "E♭" or "Bbb".
  def self.parse(text)
    match = /\A([A-Ga-g])([#b♯♭]{0,2})\z/.match(text.to_s.strip)
    match && from_name(match[1].upcase + match[2].tr("♯♭", "#b"))
  end

  # Splits a leading key name off a string such as "C#maj7" or "Bb Dorian",
  # preferring the longest name that matches. Returns [key, rest], or
  # [nil, string] when the string doesn't start with a key.
  def self.extract(string)
    @longest_first ||= all.sort_by { |k| -k.name.length }
    key = @longest_first.find { |k| string.start_with?(k.name) }
    key ? [key, string.delete_prefix(key.name)] : [nil, string]
  end

  def self.default
    self['C']
  end

  def ==(other)
    name == other.name
  end

  def to_s
    name
  end

  def to_param
    name
  end

  def main?
    name == 'C'
  end

  # Sharps (positive) or flats (negative) in the name: 1 for F#, -2 for Bbb.
  def accidental
    name[1..].count("#") - name[1..].count("b")
  end

  def double?
    accidental.abs > 1
  end

  # How far the written octave differs from the octave the pitch sounds in:
  # Cb4 sounds as B3 and B#3 as C4.
  def octave_offset
    if letter_index == 0 && index >= 10 then 1
    elsif letter_index == 6 && index <= 1 then -1
    else 0
    end
  end

  # The key a number of semitones away, spelled from the scale degree it
  # lands on. `letter_offset` is the number of letters to move (1 for any
  # kind of 2nd, 4 for any kind of 5th); when it is omitted the degree is
  # read from the semitones, see DegreeLetterOffsets. The letter wins unless
  # it would need a double accidental, so a ii in E is F# and a bII in C is
  # Db, while a bII in Db is D rather than Ebb.
  def shifted(offset, letter_offset = nil)
    letter_offset ||= DegreeLetterOffsets[offset % 12]
    self.class.spelled((index + offset) % 12, (letter_index + letter_offset) % 7)
  end

  # The root of a chord on a degree of this key. Like shifted, except that a
  # lowered degree (bII, bIII, bVI or bVII) landing on Cb or Fb is written B
  # or E: those chords are tritone substitutes and borrowed chords, which
  # players write with the simpler name (B7 rather than Cb7 for the bII7 in
  # Bb), and spelled from Cb or Fb they would need double flats.
  def degree_root(offset, letter_offset = nil)
    letter_offset ||= DegreeLetterOffsets[offset % 12]
    root = shifted(offset, letter_offset)
    lowered = offset % 12 == (MajorScaleSteps[letter_offset % 7] - 1) % 12

    lowered && %w[Cb Fb].include?(root.name) ? self.class.from_index(root.index) : root
  end

  def enharmonic_with?(another_key)
    index == another_key.index
  end

  def as_json(_options = nil)
    {
      id: name,
      name: name,
      long_name: long_name,
      index: index,
      letter_index: letter_index,
      cycle_index: cycle_index,
      primary: primary
    }
  end
end
