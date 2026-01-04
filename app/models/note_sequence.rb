require "set"

class NoteSequence
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include Enumerable
  include KeyContext

  attr_accessor :keys
  attr_accessor :invalid_keys

  def initialize(value = [])
    @value_as_given = value
    @keys = []
    @invalid_keys = []
  
    value = value.split(/ /).map(&:strip) if value.instance_of?(String)
    value.each do |key_name|
      key_object = Key[key_name]
    
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
    if key
      "#{name} in #{key}"
    else
      name
    end
  end

  def notes
    keys.map(&:name)
  end
  def staff_notes
    octavized_notes.map {|n| [n]}
  end

  # TODO: This is duplicated! Bad bad!
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


  class << self
    def resolve(value)
      sequence = new(value)
      if sequence.invalid_keys.empty? and sequence.keys.size > 0
        sequence
      else
        nil
      end
    end
    
    alias_method :[], :resolve
  end

  delegate :each, :to => :keys

  # Chords associated with this collection of notes
  def chords
    if key
      chords_in_key(key)
    else
      Key.primaries.map do |in_key|
        chords_in_key(in_key)
      end.flatten.compact
    end.extend(Chords)
  end

  # Scales associated with this collection of notes (just done through chords)
  def modes
    chords.map(&:modes).flatten
  end

  private

  def chords_in_key(in_key)
    Chord.all.select do |c|
      c.tones.map(&:tone).to_set == keys.map {|k| (k.index - (in_key ? in_key.index : 0)) % 12 }.to_set
    end.map {|c| c.key = in_key; c}
  end

end
