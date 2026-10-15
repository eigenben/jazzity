# A chord as a pianist plays it: a voicing at definite pitches and, for a
# rootless voicing, the root under it in the left hand. Knows which notes
# go on which staff of a grand staff.
class VoicedChord
  # A voicing wider than this is split at its widest gap, and its lower
  # notes join the root in the left hand, unless its family says where to
  # split it.
  ONE_HAND_SPAN = 16

  attr_reader :chord, :voicing, :pitches, :root

  def initialize(chord:, voicing:, pitches:, root: nil)
    @chord = chord
    @voicing = voicing
    @pitches = pitches
    @root = root
  end

  def to_s
    "#{chord.short_name} (#{name})"
  end

  def name
    voicing&.name || "Chord tones"
  end

  def over_root?
    !root.nil?
  end

  def notes
    pitches.map(&:to_s)
  end

  def treble
    split? ? pitches.drop(left_hand_count) : []
  end

  def bass
    split? ? [root, *pitches.first(left_hand_count)].compact : pitches
  end

  # Everything the staff needs to draw this chord: its symbol and the notes
  # on each staff.
  def to_staff
    {:symbol => chord.lead_sheet_symbol, :bass => bass.map(&:to_s), :treble => treble.map(&:to_s)}
  end

  # Everything a player needs to sound this chord: its symbol, the MIDI
  # notes for each hand, and their names, left hand first.
  def to_playback
    {:symbol => chord.lead_sheet_symbol, :left => bass.map(&:midi), :right => treble.map(&:midi), :names => (bass + treble).map(&:name)}
  end

  private

  def split?
    over_root? || two_handed?
  end

  def two_handed?
    voicing&.voicing_family&.two_handed? || false
  end

  def left_hand_count
    @left_hand_count ||= begin
      midis = pitches.map(&:midi)
      if two_handed?
        voicing.voicing_family.left_hand_tones_count
      elsif midis.last - midis.first > ONE_HAND_SPAN
        gaps = midis.each_cons(2).map { |a, b| b - a }
        gaps.index(gaps.max) + 1
      else
        0
      end
    end
  end
end
