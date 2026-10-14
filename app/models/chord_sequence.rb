# Chords written one after another, as in "Dm7 G7 Cmaj7", "Dm7, G7, C",
# "Dm7 | G7 | Cmaj7" or "Dm7-G7-C". Each chord is read by ChordName and
# must have a root.
#
# A sequence has a home key: the key of a known progression it matches,
# or else the key its last chord settles in. `in_key_of` moves the whole
# sequence into another key, each chord keeping its degree, so Dm7 G7 Cmaj7
# in Bb is Cm7 F7 Bbmaj7.
class ChordSequence
  include Routable
  include Enumerable
  include KeyContext

  # Spaces, commas and barlines separate chords, and so does a dash
  # before a root (Dm7-G7-C), though not the dash of a minor chord (C-7).
  SEPARATORS = /[\s,|]+|-(?=[A-G])/

  attr_accessor :chords
  attr_accessor :chord_names
  attr_accessor :invalid_chords
  attr_writer :home_key

  def initialize(value = [])
    @value_as_given = value
    @chords = []
    @chord_names = []
    @invalid_chords = []

    value = value.split(SEPARATORS).reject { |name| name.blank? || name.match?(%r{\A[/%]+\z}) } if value.instance_of?(String)
    value.each do |item|
      if item.is_a?(Chord)
        @chords << item
        @chord_names << item.lead_sheet_symbol
      elsif (name = ChordName.parse(item))&.rooted?
        @chords << name.chord
        @chord_names << name.to_s
      else
        @invalid_chords << item
      end
    end
  end

  def to_s
    name
  end

  def name
    chord_names.join(", ")
  end

  def to_param
    chord_names.join(",")
  end

  def title
    if key
      "#{name} in #{key}"
    else
      name
    end
  end

  def chord_key_offsets
    last_i = nil
    chords.map(&:key).map(&:index).inject([]) do |offsets, i|
      offsets << (i - last_i) % 12 if last_i
      last_i = i
      offsets
    end
  end

  # The chords voiced in a family, see VoiceLeader.
  def voiced_chords(family: nil, overrides: {})
    VoiceLeader.new(chords, family: family, overrides: overrides).voiced_chords
  end

  def notes
    chords.map(&:notes)
  end
  def octavized_notes
    chords.map(&:octavized_notes)
  end
  # The voiced chords for a grand staff, a bar each.
  def staff_notes(voiced = voiced_chords)
    voiced.map(&:to_staff)
  end

  class << self
    def resolve(value)
      collection = new(value)
      if collection.invalid_chords.empty? and collection.chords.size > 1
        collection
      else
        nil
      end
    end

    alias_method :[], :resolve
  end

  delegate :each, :to => :chords

  # The same chords on the same degrees of another key.
  def in_key_of(key)
    key = Key[key] unless key.nil? || key.is_a?(Key)
    return self if key.nil? || chords.empty?

    home = home_key
    transposed = chords.map do |chord|
      offset = (chord.key.index - home.index) % 12
      letters = (chord.key.letter_index - home.letter_index) % 7
      chord.clone.tap { |moved| moved.key = key.degree_root(offset, letters) }
    end

    self.class.new(transposed).tap do |sequence|
      sequence.key = key
      sequence.home_key = key
    end
  end

  # The key the sequence is in: that of a known progression with the same
  # chords, or else the key of its last chord when that's major or minor,
  # the key it resolves to when that's a dominant, or the first chord's root.
  def home_key
    @home_key ||= progressions.first&.key || closing_key
  end

  # Known progressions with chords of the same kinds on the same roots,
  # placed in the key that matches.
  def progressions
    return [] if chords.empty?

    Progression.includes(:components => {:chord => :chord_quality}).filter_map do |progression|
      components = progression.components.to_a
      next unless components.size == chords.size && components.all?(&:chord)

      key = components.first.key_from_root(chords.first.key)
      matches = chords.zip(components).all? do |chord, component|
        (chord.key.index - key.index) % 12 == component.index && chord.chord_quality_id == component.chord.chord_quality_id
      end
      progression.in_key_of(key) if matches
    end
  end

  private

  def closing_key
    last = chords.last
    return if last.nil?

    case last.chord_quality.name
    when "Major", "Minor" then last.key
    when "Dominant" then last.key.shifted(5, 3)
    else chords.first.key
    end
  end
end
