class VoiceLeading < ActiveRecord::Base
  belongs_to :from_voicing, class_name: "Voicing"
  belongs_to :to_voicing, class_name: "Voicing"

  scope :from_chord, ->(c) { joins("INNER JOIN voicings AS from_voicings ON from_voicings.id = voice_leadings.from_voicing_id").where(from_voicings: { chord_id: c.id }) }
  scope :to_chord, ->(c) { joins("INNER JOIN voicings AS to_voicings ON to_voicings.id = voice_leadings.to_voicing_id").where(to_voicings: { chord_id: c.id }) }

  def self.define_all(leadings)
    leadings.each do |leading|
      define(leading[0], leading[1], leading[2], leading[3])
    end
  end

  def self.define(offset, from_voicing, to_voicing, changed_tones = nil)
    if from_voicing and to_voicing
      create!(offset: offset, from_voicing: from_voicing, to_voicing: to_voicing, changed_tones: changed_tones || 1)
    end
  end

  # Determines a good set of voicings using voice leading rules for the given set of chords.
  # Currently if it can't find one, it will choose a random voicing! (Dangerous?)
  #
  def self.voicings_for_chords(chords, voicing_ids = {})
    voicing_ids.stringify_keys!

    [].tap do |voicings|
      chords.each_with_index do |chord, i|
        choice = voicing_ids[i.to_s]
        previous_voicing = voicings.last

        if choice == "<" or choice.nil?
          voicings << (voicing_for_chord_after(chord, previous_voicing) || chord.voicings.sample.try(:in_key_of, chord.key))
        elsif choice.to_i > 0
          voicings << chord.voicings.find(choice).in_key_of(chord.key)
        end
      end
    end.compact
  end

  def self.voicing_for_chord_after(chord, previous_voicing)
    if leading = for_chord_after(chord, previous_voicing).try(:sample)
      leading.to_voicing.in_key_of(chord.key)
    end
  end

  def self.for_chord_after(chord, previous_voicing)
    if chord && previous_voicing
      offset = (chord.key.index - previous_voicing.key.index) % 12
      previous_voicing.voice_leadings_from.where(offset: offset).to_chord(chord)
    end
  end

end
