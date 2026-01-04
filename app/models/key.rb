class Key
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attr_reader :name, :long_name, :index, :letter_index, :cycle_index, :primary

  Letters = { 'C' => 0, 'D' => 1, 'E' => 2, 'F' => 3, 'G' => 4, 'A' => 5, 'B' => 6 }
  Steps = { 'H' => 1, 'W' => 2, 'm3' => 3, 'M3' => 4, '4' => 5, '#4' => 6, '5' => 7 }

  Intervals = {
    'u' => 0, 'unison' => 0, '0' => 0,
    'b2' => 1, 'b9' => 1, 'min2' => 1, 'S' => 1, 'H' => 1, 'm2' => 1,
    'M2' => 2, '9' => 2, 'maj2' => 2, 'T' => 2, 'W' => 2, '2' => 2,
    'b3' => 3, 'min3' => 3, '#2' => 3, '#9' => 3, 'm3' => 3,
    '3' => 4, 'maj3' => 4, 'M3' => 4,
    'p4' => 5, '4' => 5,
    'b5' => 6, 'aug4' => 6, 'dim5' => 6, '#4' => 6,
    'p5' => 7, '5' => 7,
    'b6' => 8, 'aug5' => 8, '#5' => 8,
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
    'p4' => 3, '4' => 3,
    'b5' => 4, 'aug4' => 3, 'dim5' => 4, '#4' => 3,
    'p5' => 4, '5' => 4,
    'b6' => 5, 'aug5' => 4, '#5' => 4,
    'M6' => 5, 'maj6' => 5, '6' => 5,
    'm7' => 6, 'min7' => 6, 'dom7' => 6, 'b7' => 6,
    'maj7' => 6, 'M7' => 6, '7' => 6,
    '8' => 7, 'octave' => 7
  }

  def initialize(attributes = {})
    @primary = true

    attributes.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end

  def self.all
    [
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
    ]
  end

  def self.all_without_doubles
    [
      Key.new(name: 'C', long_name: 'C', index: 0, letter_index: 0, cycle_index: 0),
      Key.new(name: 'B#', long_name: 'B Sharp', index: 0, letter_index: 6, cycle_index: 0,
              primary: false),
      Key.new(name: 'C', long_name: 'C', index: 0, letter_index: 1, cycle_index: 0, primary: false),

      Key.new(name: 'F', long_name: 'F', index: 5, letter_index: 3, cycle_index: 1),
      Key.new(name: 'E#', long_name: 'E Sharp', index: 5, letter_index: 2, cycle_index: 1,
              primary: false),
      Key.new(name: 'F', long_name: 'F', index: 5, letter_index: 4, cycle_index: 1, primary: false),

      Key.new(name: 'Bb', long_name: 'B Flat', index: 10, letter_index: 6, cycle_index: 2),
      Key.new(name: 'A#', long_name: 'A Sharp', index: 10, letter_index: 5, cycle_index: 2,
              primary: false),
      Key.new(name: 'Bb', long_name: 'B Flat', index: 10, letter_index: 0, cycle_index: 2,
              primary: false),

      Key.new(name: 'Eb', long_name: 'E Flat', index: 3, letter_index: 2, cycle_index: 3),
      Key.new(name: 'D#', long_name: 'D Sharp', index: 3, letter_index: 1, cycle_index: 3,
              primary: false),
      Key.new(name: 'Eb', long_name: 'E Flat', index: 3, letter_index: 3, cycle_index: 3,
              primary: false),

      Key.new(name: 'Ab', long_name: 'A Flat', index: 8, letter_index: 5, cycle_index: 4),
      Key.new(name: 'G#', long_name: 'G Sharp', index: 8, letter_index: 4, cycle_index: 4,
              primary: false),

      Key.new(name: 'Db', long_name: 'D Flat', index: 1, letter_index: 1, cycle_index: 5),
      Key.new(name: 'C#', long_name: 'C Sharp', index: 1, letter_index: 0, cycle_index: 5,
              primary: false),
      Key.new(name: 'C#', long_name: 'C Sharp', index: 1, letter_index: 6, cycle_index: 5,
              primary: false),

      Key.new(name: 'Gb', long_name: 'G Flat', index: 6, letter_index: 4, cycle_index: 6),
      Key.new(name: 'F#', long_name: 'F Sharp', index: 6, letter_index: 3, cycle_index: 6,
              primary: false),
      Key.new(name: 'F#', long_name: 'F Sharp', index: 6, letter_index: 2, cycle_index: 6,
              primary: false),

      Key.new(name: 'B', long_name: 'B', index: 11, letter_index: 6, cycle_index: 7),
      Key.new(name: 'Cb', long_name: 'C Flat', index: 11, letter_index: 0, cycle_index: 7,
              primary: false),
      Key.new(name: 'B', long_name: 'B', index: 11, letter_index: 5, cycle_index: 7, primary: false),

      Key.new(name: 'E', long_name: 'E', index: 4, letter_index: 2, cycle_index: 8),
      Key.new(name: 'Fb', long_name: 'F Flat', index: 4, letter_index: 3, cycle_index: 8,
              primary: false),
      Key.new(name: 'E', long_name: 'E', index: 4, letter_index: 1, cycle_index: 8, primary: false),

      Key.new(name: 'A', long_name: 'A', index: 9, letter_index: 5, cycle_index: 9),
      Key.new(name: 'A', long_name: 'A', index: 9, letter_index: 6, cycle_index: 9, primary: false),
      Key.new(name: 'A', long_name: 'A', index: 9, letter_index: 4, cycle_index: 9, primary: false),

      Key.new(name: 'D', long_name: 'D', index: 2, letter_index: 1, cycle_index: 10),
      Key.new(name: 'D', long_name: 'D', index: 2, letter_index: 0, cycle_index: 10, primary: false),
      Key.new(name: 'D', long_name: 'D', index: 2, letter_index: 2, cycle_index: 10, primary: false),

      Key.new(name: 'G', long_name: 'G', index: 7, letter_index: 4, cycle_index: 11),
      Key.new(name: 'G', long_name: 'G', index: 7, letter_index: 3, cycle_index: 11, primary: false),
      Key.new(name: 'G', long_name: 'G', index: 7, letter_index: 5, cycle_index: 11, primary: false)
    ]
  end

  def self.primaries
    all_without_doubles.select(&:primary)
  end

  def self.from_index(value, preferred_letter = nil)
    all_without_doubles.find { |k| k.index == value && (preferred_letter.nil? || k.letter_index == preferred_letter) }
  end

  def self.from_name(value)
    all_without_doubles.find { |k| k.name == value }
  end

  def self.[](value)
    from_name(value) || from_index(value)
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

  def shifted(offset)
    self.class.primaries.find { |k| ((index + offset) % 12) == k.index }
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
