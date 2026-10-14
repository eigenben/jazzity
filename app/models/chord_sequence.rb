class ChordSequence
  include Routable
  include Enumerable
  include KeyContext

  attr_accessor :chords
  attr_accessor :chord_names
  attr_accessor :invalid_chords


  def initialize(value = [])
    @value_as_given = value
    @chords = []
    @chord_names = []
    @invalid_chords = []

    value = value.split(/,| /).map(&:strip).reject(&:blank?) if value.instance_of?(String)
    value.each do |chord_name|
      chord_object = chord_name.is_a?(Chord) ? chord_name : Chord[chord_name]

      if chord_object.nil?
        @invalid_chords << chord_name
      else
        @chords << chord_object
        @chord_names << chord_name.to_s
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

  def chord_voicings(voicing_ids = {})
    VoiceLeading.voicings_for_chords(chords, voicing_ids)
  end

  def chord_voicing_notes(voicing_ids = {})
    chord_voicings(voicing_ids).map do |voicing|
      voicing.octavized_notes(3)
    end
  end

  def notes
    chords.map(&:notes)
  end
  def octavized_notes
    chords.map(&:octavized_notes)
  end
  def staff_notes(voicing_ids = {})
    chord_voicing_notes(voicing_ids)
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

  # This is not very efficient; everything is loaded into memory... Not sure how to do this in SQL without caching:
  # TODO: Needs key_context - determine which key this progression is in!
  #
  def progressions
    Progression.all.select do |progression|
      i = 0
      chords.all? do |chord|
        component = progression.components[i]; i += 1
        component.try(:chord) == chord
      end and chord_key_offsets == progression.component_index_offsets
    end.map do |progression|
      progression.in_key_of chords.first.key.shifted(-1 * progression.components.first.index)
    end
  end
end
