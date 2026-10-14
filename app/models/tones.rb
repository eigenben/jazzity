module Tones
  # Takes manually specified key context for this collection or
  # delegates to th association owner.
  def key
    @key || (proxy_owner.key if defined?(proxy_owner) and proxy_owner.respond_to?(:key))
  end

  # Manually specifies the key context for this tone sequence only.
  def in_key_of(in_key = nil)
    @key = in_key.is_a?(Key) ? in_key : Key[in_key]
    self
  end

  # Shifts indexes to simulate a key change
  def in_key_context!
    self.each do |tone|
      tone.tone = (tone.tone + key.index) % 12
      tone.letter_index = (tone.letter_index + key.letter_index) % 7
    end
    true
  end

  # Takes manually specified mode context for this collection or
  # delegates to the association owner.
  def mode
    @mode || (proxy_owner.mode if defined?(proxy_owner) and proxy_owner.respond_to?(:mode))
  end

  # Manually specifies the mode context for this tone sequence only.
  def in_mode(mode)
    @mode = mode
    self
  end

  # Shifts mode positions to place tone sequence in mode context
  def in_mode_context!
    self.each { |tone| tone.position = (tone.position - mode) % self.count + 1 }
    true
  end

  # TODO: Is this needed anymore? Have to use this until we figure out how to override find/default collection result
  def all
    in_key_context! if key
    in_mode_context! if mode
    self.sort_by(&:position)
  end

  # Does the magic in determining the actual note from the tones
  # with tone and letter indexes.
  def keys
    return @keys if defined?(@keys)

    @keys = all.map do |tone|
      Key.from_index(tone.tone, tone.letter_index)
    end
  end

  def notes
    keys.map(&:name)
  end

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

  def intervals
    previous = 0
    keys.map(&:index).map do |index|
      (index - previous).tap { previous = index }
    end[1..-1].map { |i| i % 12 }
  end

  def step_names
    intervals.map { |step| Key::Steps.invert[step] }
  end

  def interval_names
    intervals.map { |step| Key::Intervals.invert[step] }
  end
end
