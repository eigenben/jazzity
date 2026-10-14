# A progression's changes reharmonized in one of the ways jazz players do
# it, each a pure function from one run of chords to another:
#
# - Tritone substitutes: a dominant 7th resolving down a fifth becomes the
#   dominant a tritone away, which shares its 3rd and 7th (G7 to Db7).
# - Related ii chords: a dominant 7th gets the ii of its own ii-V before it
#   (A7 Dm7 becomes Em7b5 A7 Dm7).
# - Backdoor dominants: a V7 resolving to a major chord comes in from bVII7
#   instead, its ii becoming iv7 (Dm7 G7 Cmaj7 becomes Fm7 Bb7 Cmaj7).
# - Passing diminished chords: a diminished 7th on the half step between
#   chords a whole step apart (Cmaj7 C#°7 Dm7), or in place of a dominant
#   whose 3rd is a half step above the chord before (A7 is C#°7 with a root).
#
# A dominant on the tonic, such as the I7 of a blues, is left alone, and the
# last chord leads back to the first, as a progression goes round again, or
# else to the tonic.
#
#   Reharmonization.all(Progression["Major I-VI-ii-V"].changes).map { |r| r.chords.map(&:lead_sheet_symbol) }
class Reharmonization
  KINDS = {
    :tritone_substitutes => ["Tritone substitutes", "Each dominant 7th that resolves down a fifth becomes the dominant a tritone away, which shares its 3rd and 7th, so the bass moves by half steps."],
    :related_iis => ["Related ii chords", "Each dominant 7th gets the ii chord of its own ii-V before it, half a dominant's time each."],
    :backdoor => ["Backdoor dominants", "Each V7 resolving to a major chord comes in by the back door from bVII7, with iv7 for its ii, borrowed from the minor key."],
    :passing_diminished => ["Passing diminished chords", "Diminished 7ths on the half steps between chords a whole step apart, or in place of a dominant whose 3rd is a half step above the chord before."]
  }.freeze

  attr_reader :kind, :chords, :changed, :key

  # `changed` are the indexes of the chords that are new.
  def initialize(kind, chords, changed, key: nil)
    @kind = kind
    @chords = chords
    @changed = changed
    @key = key
  end

  # Every reharmonization that changes something, in the key given (C
  # when there's none).
  def self.all(chords, key: nil)
    chords = chords.to_a
    return [] if chords.size < 2

    tonic = key || Key.default
    KINDS.keys.filter_map do |kind|
      new_chords, changed = Rewriter.new(chords, tonic).public_send(kind)
      new(kind, new_chords, changed, key: key) if changed.any?
    end
  end

  def name
    KINDS[kind].first
  end

  def description
    KINDS[kind].last
  end

  def changed?(index)
    changed.include?(index)
  end

  # The new chords as a sequence in the key, to analyze.
  def chord_sequence
    ChordSequence.in_key(chords, key)
  end

  # Rewrites a run of chords. Each rewrite returns the new chords and the
  # indexes of those it added or replaced.
  class Rewriter
    def initialize(chords, tonic)
      @chords = chords
      @tonic = tonic
    end

    def tritone_substitutes
      rewrite do |chord, i|
        next unless functioning_dominant?(i)

        target = target_of(i)
        [[build(chord.name == "Altered" ? "7#11" : "7", target.key.degree_root(1, 1)), true]]
      end
    end

    def related_iis
      rewrite do |chord, i|
        next unless functioning_dominant?(i) && !preceded_by_ii?(i)

        quality = %w[Minor Diminished].include?(target_of(i).chord_quality.name) ? "m7b5" : "m7"
        [[build(quality, chord.key.shifted(7, 4)), true], [chord, false]]
      end
    end

    def backdoor
      rewrite do |chord, i|
        following = @chords[i + 1]
        if functioning_dominant?(i) && target_of(i).chord_quality.name == "Major"
          [[build("7", target_of(i).key.degree_root(10, 6)), true]]
        elsif following && preceded_by_ii?(i + 1) && functioning_dominant?(i + 1) && target_of(i + 1).chord_quality.name == "Major"
          [[build("m7", target_of(i + 1).key.shifted(5, 3)), true]]
        end
      end
    end

    def passing_diminished
      rewrite do |chord, i|
        following = @chords[i + 1]
        previous = @chords[i - 1] if i.positive?

        if functioning_dominant?(i) && previous && interval(previous, chord) == 9
          [[build("dim7", chord.key.shifted(4, 2)), true]]
        elsif following && interval(chord, following) == 2
          [[chord, false], [build("dim7", chord.key.shifted(1, 0)), true]]
        end
      end
    end

    private

    # Builds the new run of chords: the block gives the chords to put in
    # place of each one, each with whether it's new, or nil to keep it.
    def rewrite
      chords = []
      changed = []

      @chords.each_with_index do |chord, i|
        (yield(chord, i) || [[chord, false]]).each do |new_chord, added|
          changed << chords.size if added
          chords << new_chord
        end
      end

      [chords, changed]
    end

    # A dominant 7th, not on the tonic, resolving down a fifth.
    def functioning_dominant?(i)
      chord = @chords[i]
      chord.chord_quality.name == "Dominant" && chord.key.index != @tonic.index && interval(chord, target_of(i)) == 5
    end

    # The chord before is the ii of this dominant's ii-V.
    def preceded_by_ii?(i)
      previous = @chords[i - 1] if i.positive?
      previous && %w[Minor Diminished].include?(previous.chord_quality.name) && interval(previous, @chords[i]) == 5
    end

    # The chord a chord leads to: the next one, or after the last, the
    # first when the progression starts on the tonic, or else the tonic.
    def target_of(i)
      @chords[i + 1] || (@chords.first if @chords.first.key.index == @tonic.index) || build("maj7", @tonic)
    end

    def interval(chord, following)
      (following.key.index - chord.key.index) % 12
    end

    def build(symbol, root)
      ChordName.find_symbol(symbol).chord.clone.tap { |chord| chord.key = root }
    end
  end
end
