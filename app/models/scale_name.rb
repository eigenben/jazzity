# A scale or mode named the way musicians say it, with its key before or
# after the name: "D Dorian", "dorian D", "Dorian in D", "D Dorian scale",
# "f# melodic minor" or "Bb major scale".
#
#   ScaleName.parse("Ab Lydian Augmented").target.title  # => "Ab Lydian Augmented"
#
# The key is the note the scale or mode starts on. A mode is a mode of a
# parent scale in another key (D Dorian is the C major scale from D), so
# `target` places the mode's parent in the key that puts the mode on that
# note. A few common names stand for a mode: "minor" and "natural minor" for
# Aeolian, "altered" for Super Locrian. "C major" and "C minor" are scales:
# the chords are written Cmaj and Cm.
class ScaleName
  ALIASES = {
    "ionian" => "Major",
    "minor" => "Aeolian",
    "natural minor" => "Aeolian",
    "jazz minor" => "Melodic Minor",
    "altered" => "Super Locrian",
    "lydian b7" => "Lydian Dominant",
    "locrian natural 2" => "Locrian #2",
    "dominant diminished" => "Half-Whole",
    "major pentatonic" => "Pentatonic"
  }.freeze

  attr_reader :key, :model

  def initialize(key, model)
    @key = key
    @model = model
  end

  def self.parse(text)
    KeyedQuery.parse(text).each do |reading|
      model = lookup(reading.text)
      return new(reading.key, model) if model
    end

    nil
  end

  # The scale or mode, in the key that starts it on the note asked for.
  def self.resolve(text)
    parse(text)&.target
  end

  # Scales and modes by their normalized names: a scale under its own name,
  # each mode under its name unless it's the scale's first mode, which is
  # the scale itself (Ionian is the major scale).
  def self.names
    scales = Scale.includes(:modes).to_a
    names = scales.index_by { |scale| normalize(scale.name) }
    scales.flat_map(&:modes).each do |mode|
      names[normalize(mode.name)] ||= mode.main? ? mode.scale : mode
    end
    ALIASES.each { |name, canonical| names[name] ||= names[normalize(canonical)] }
    names
  end

  def self.lookup(text)
    names[normalize(text)]
  end

  # Lowercase, single spaces, hyphens as spaces, and without a leading
  # "the" or a trailing "scale" or "mode".
  def self.normalize(text)
    text.to_s.tr("♯♭", "#b").tr("-", " ").squish.downcase.delete_prefix("the ").sub(/ (?:scale|mode)\z/, "")
  end

  def scale?
    model.is_a?(Scale)
  end

  def target
    scale? ? model.in_key_of(key) : model.in_key_of(parent_key)
  end

  def to_s
    [key, model.name].compact.join(" ")
  end

  private

  # The key of the scale the mode comes from, when it starts on `key`.
  def parent_key
    return if key.nil?

    start = Key[model.notes.first]
    key.shifted(-start.index, -start.letter_index)
  end
end
