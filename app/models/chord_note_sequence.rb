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
  
    value = value.split(/,/).map(&:strip).reject(&:blank?) if value.instance_of?(String)
    value.each do |key_group|
      note_sequence = NoteSequence[key_group]
      
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
    if key
      "#{name} in #{key}"
    else
      name
    end
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

  # TODO:
  def progressions
    Progression.all
  end

  # Progressions associated with this collection of notes
  # def progressions
  #   if key
  #     chords_in_key(key)
  #   else
  #     Key.primaries.map do |in_key|
  #       chords_in_key(in_key)
  #     end.flatten
  #   end.extend(Chords)
  # end

  # private

  # def chords_in_key(in_key)
  #   Chord.all.select do |c|
  #     c.tones.map(&:tone).to_set == keys.map {|k| (k.index - (in_key ? in_key.index : 0)) % 12 }.to_set
  #   end.map {|c| c.key = in_key; c}
  # end

end
