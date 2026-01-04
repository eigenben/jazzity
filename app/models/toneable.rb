module Toneable
  extend ActiveSupport::Concern

  included do
    serialize :tone_values, coder: JSON

    delegate :notes, :to => :tones
    delegate :octavized_notes, :to => :tones
    delegate :intervals, :to => :tones
    delegate :step_names, :to => :tones
    delegate :interval_names, :to => :tones
  end

  def tones
    @tones ||= tone_values.map {|v| Tone.new(v) }.extend(Tones)
  end

  def specify_tones=(values)
    @specify_tones = values

    new_tones = []
    values = values.split(" ") if values.is_a?(String)
    values.each_with_index do |value, i|
      tone = Key::Intervals[value]
      letter_index = Key::IntervalLetterIndexes[value]
      raise ArgumentError, "Could not find interval '#{value}' within '#{values.join(', ')}'" if tone.nil? or letter_index.nil?

      new_tones << Tone.new(:tone => tone, :letter_index => letter_index, :position => (i + 1))
    end

    self.tone_values = new_tones
    self
  end

  def staff_notes
    octavized_notes
  end

end
