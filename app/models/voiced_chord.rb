# A chord as a pianist plays it: a voicing at definite pitches and, for a
# rootless voicing, the root under it in the left hand. Knows which notes
# go on which staff of a grand staff.
class VoicedChord
  # A voicing wider than this (a two-handed upper structure) is split at its
  # widest gap, and its lower notes join the root in the left hand.
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
    over_root? ? pitches.drop(left_hand_count) : []
  end

  def bass
    over_root? ? [root, *pitches.first(left_hand_count)] : pitches
  end

  # Everything the staff needs to draw this chord: its symbol and the notes
  # on each staff.
  def to_staff
    {:symbol => chord.lead_sheet_symbol, :bass => bass.map(&:to_s), :treble => treble.map(&:to_s)}
  end

  private

  def left_hand_count
    @left_hand_count ||= begin
      midis = pitches.map(&:midi)
      if midis.last - midis.first > ONE_HAND_SPAN
        gaps = midis.each_cons(2).map { |a, b| b - a }
        gaps.index(gaps.max) + 1
      else
        0
      end
    end
  end
end
