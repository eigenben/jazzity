module KeyboardHelper
  WHITE_KEY = {:width => 12, :height => 56}.freeze
  BLACK_KEY = {:width => 7, :height => 34}.freeze
  BLACK_PITCH_CLASSES = [1, 3, 6, 8, 10].freeze
  # The fewest octaves a keyboard shows, so a chord isn't drawn on a toy.
  MIN_OCTAVES = 2

  # A piano keyboard drawn in SVG with the notes of a chord, voicing or
  # scale marked on it: `right` in the right hand's colour and `left` (the
  # root under a rootless voicing, or a left-hand voicing) in the left's.
  # Notes are Pitches or MIDI numbers. The keyboard spans whole octaves (from
  # C or F to E or B) around the notes, or `range` when given, so a player
  # can mark other chords of a progression on the same keys.
  def keyboard_tag(right = [], left: [], range: nil, label: nil, **options)
    left = left.map { |note| keyboard_pitch(note) }
    right = right.map { |note| keyboard_pitch(note) }
    range ||= keyboard_range(left + right)
    whites = range.reject { |midi| black_key?(midi) }
    hands = left.to_h { |pitch| [pitch.midi, [:left, pitch]] }.merge(right.to_h { |pitch| [pitch.midi, [:right, pitch]] })

    keys = whites.each_with_index.map { |midi, i| keyboard_key(midi, i * WHITE_KEY[:width], hands[midi]) }
    keys += range.select { |midi| black_key?(midi) }.map do |midi|
      x = (whites.index(midi - 1) + 1) * WHITE_KEY[:width] - BLACK_KEY[:width] / 2.0
      keyboard_key(midi, x, hands[midi])
    end

    width = whites.size * WHITE_KEY[:width]
    tag.svg(safe_join(keys), class: ["keyboard", options.delete(:class)], viewBox: "-1 -1 #{width + 2} #{WHITE_KEY[:height] + 2}",
      role: "img", aria: {label: label || keyboard_label(left, right)}, style: "--keyboard-keys: #{whites.size}",
      data: {:controller => "keyboard"}.merge(options.delete(:data) || {}), **options)
  end

  # Whole octaves, at least MIN_OCTAVES of them, from the C or F at or below
  # the lowest note to the E or B at or above the highest.
  def keyboard_range(pitches)
    midis = pitches.map { |pitch| keyboard_pitch(pitch).midi }
    return 60..(59 + MIN_OCTAVES * 12) if midis.empty?

    low = midis.min - [0, 5].map { |start| (midis.min - start) % 12 }.min
    high = midis.max + [4, 11].map { |finish| (finish - midis.max) % 12 }.min
    high += 12 while high - low + 1 < MIN_OCTAVES * 12
    low..high
  end

  # What a screen reader says for a keyboard: the notes marked on it, by hand.
  def keyboard_label(left, right)
    names = ->(pitches) { pitches.map(&:name).join(" ") }
    marked = if left.any? && right.any? then "left hand #{names.call(left)}, right hand #{names.call(right)}"
    elsif left.any? then "left hand #{names.call(left)}"
    else names.call(right)
    end
    ["Piano keyboard", marked.presence].compact.join(": ")
  end

  private

  def keyboard_pitch(note)
    note.is_a?(Pitch) ? note : Pitch.new(Key.from_index(note), note)
  end

  def black_key?(midi)
    BLACK_PITCH_CLASSES.include?(midi % 12)
  end

  # A key, with its note name written on it when it's marked and with the
  # octave on each C, so the keyboard can be read at a glance.
  def keyboard_key(midi, x, (hand, pitch))
    black = black_key?(midi)
    size = black ? BLACK_KEY : WHITE_KEY
    default = "C#{midi / 12 - 1}" if midi % 12 == 0
    text = pitch ? pitch.key.name.gsub(/(?<=.)b/, "♭").tr("#", "♯") : default

    tag.g(class: ["keyboard-key", black ? "keyboard-black" : "keyboard-white", ("is-#{hand}" if hand)], data: {midi: midi, default: default}) do
      tag.rect(x: x, y: 0, width: size[:width], height: size[:height], rx: 1.5) +
        tag.text(text, x: x + size[:width] / 2.0, y: size[:height] - (black ? 4 : 5), class: ("keyboard-octave" unless pitch), "aria-hidden": true)
    end
  end
end
