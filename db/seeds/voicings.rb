# Voicings are grouped into families. Within a family, voicings that share a
# name are built the same way on every chord (the 3rd on the bottom, say), so
# a family can voice a whole progression and move smoothly between chords.

module VoicingSeeds
  extend self

  # Creates the named voicings of a chord in a family.
  def voice(family, chord_name, voicings)
    chord = Chord.find_by!(:name => chord_name)

    voicings.each do |name, tones|
      chord.voicings.create!(:voicing_family => family, :name => name, :specify_tones => tones)
    end
  end

  # Voices several chords the same way, each with its own tones.
  def voice_all(family, names, tones_by_chord)
    tones_by_chord.each do |chord_name, tones|
      voice(family, chord_name, names.zip(Array(tones)).to_h)
    end
  end

  # The 3rd and 7th (or 6th) that define each chord's sound, used by the guide
  # tone families.
  GUIDE_TONES = {
    "Major 7" => %w[3 7], "Major 9" => %w[3 7], "Major 7 #11" => %w[3 7], "Major 7 #4#5" => %w[3 7],
    "Major 6" => %w[3 6], "Major 6/9" => %w[3 6],
    "Minor 7" => %w[b3 b7], "Minor 9" => %w[b3 b7], "Minor 11" => %w[b3 b7],
    "Minor 6" => %w[b3 6], "Minor b6" => %w[b3 b6], "Minor-Major 7" => %w[b3 7],
    "Dominant 7" => %w[3 b7], "Dominant 9" => %w[3 b7], "Dominant 13" => %w[3 b7],
    "Dominant b9" => %w[3 b7], "Dominant #9" => %w[3 b7], "Dominant #11" => %w[3 b7],
    "Dominant b13" => %w[3 b7], "Altered" => %w[3 b7], "Dominant b5" => %w[3 b7], "Augmented 7" => %w[3 b7],
    "Dominant 7 sus4" => %w[4 b7], "Dominant 9 sus4" => %w[4 b7], "Dominant 7 sus4 b9" => %w[4 b7],
    "Half Diminished" => %w[b3 b7], "Diminished 7" => %w[b3 bb7]
  }

  # The four notes of each seventh (or sixth) chord, root first.
  SEVENTH_CHORDS = {
    "Major 7" => %w[u 3 5 7],
    "Major 6" => %w[u 3 5 6],
    "Minor 7" => %w[u b3 5 b7],
    "Minor 6" => %w[u b3 5 6],
    "Minor b6" => %w[u b3 5 b6],
    "Minor-Major 7" => %w[u b3 5 7],
    "Dominant 7" => %w[u 3 5 b7],
    "Dominant b5" => %w[u 3 b5 b7],
    "Augmented 7" => %w[u 3 #5 b7],
    "Dominant 7 sus4" => %w[u 4 5 b7],
    "Half Diminished" => %w[u b3 b5 b7]
  }
end

VoicingSeeds.instance_exec do
  VoicingFamily.create!(:name => "Triads", :voicing_tones_count => 3, :rootless => false).tap do |family|
    names = ["Root Inversion", "1st Inversion", "2nd Inversion", "Doubled Root"]

    {
      "Major Triad" => %w[u 3 5],
      "Minor Triad" => %w[u b3 5],
      "Diminished Triad" => %w[u b3 b5],
      "Augmented Triad" => %w[u 3 #5],
      "Suspended 4" => %w[u 4 5]
    }.each do |chord_name, (root, third, fifth)|
      inversions = [[root, third, fifth], [third, fifth, root], [fifth, root, third], [root, third, fifth, root]]
      voice(family, chord_name, names.zip(inversions.map { |tones| tones.join(" ") }).to_h)
    end
  end


  VoicingFamily.create!(:name => "4-Note Rooted", :voicing_tones_count => 4, :rootless => false).tap do |family|
    # Root position, and the 5th and 7th on the bottom with the root and 3rd above.
    VoicingSeeds::SEVENTH_CHORDS.each do |chord_name, (root, third, fifth, seventh)|
      voice(family, chord_name, "Rooted I" => [root, third, fifth, seventh].join(" "), "Rooted II" => [fifth, seventh, root, third].join(" "))
    end

    # Every inversion of a diminished 7th is another diminished 7th.
    voice(family, "Diminished 7", "Rooted I" => "u b3 b5 bb7", "Rooted II" => "b3 b5 bb7 u", "Rooted III" => "b5 bb7 u b3", "Rooted IV" => "bb7 u b3 b5")
  end


  VoicingFamily.create!(:name => "Guide Tones", :voicing_tones_count => 2, :rootless => true).tap do |family|
    VoicingSeeds::GUIDE_TONES.each do |chord_name, (third, seventh)|
      voice(family, chord_name, "Guide Tones I" => "#{third} #{seventh}", "Guide Tones II" => "#{seventh} #{third}")
    end
  end


  VoicingFamily.create!(:name => "Rooted Guide Tones", :voicing_tones_count => 3, :rootless => false).tap do |family|
    VoicingSeeds::GUIDE_TONES.each do |chord_name, (third, seventh)|
      voice(family, chord_name, "Rooted Guide Tones I" => "u #{third} #{seventh}", "Rooted Guide Tones II" => "u #{seventh} #{third}")
    end
  end


  VoicingFamily.create!(:name => "Rootless 3-Note Shells", :voicing_tones_count => 3, :rootless => true).tap do |family|
    # Shell I has the 3rd on the bottom and Shell II the 7th (or 6th).
    voice_all(family, ["Shell I", "Shell II"], {
      "Major 7" => ["3 7 9", "7 3 5"],
      "Major 9" => ["3 7 9", "7 9 3"],
      "Major 6" => ["3 6 9", "6 9 5"],
      "Major 6/9" => ["3 6 9", "6 9 5"],
      "Minor 7" => ["b3 b7 9", "b7 b3 5"],
      "Minor 9" => ["b3 b7 9", "b7 9 b3"],
      "Minor 11" => ["b3 b7 11", "b7 b3 11"],
      "Minor 6" => ["b3 6 9", "6 b3 5"],
      "Minor b6" => ["b3 b6 9", "b6 b3 5"],
      "Minor-Major 7" => ["b3 7 9", "7 b3 5"],
      "Dominant 7" => ["3 b7 9", "b7 3 5"],
      "Dominant 9" => ["3 b7 9", "b7 9 3"],
      "Dominant 13" => ["3 b7 13", "b7 3 13"],
      "Dominant b9" => ["3 b7 b9", "b7 b9 3"],
      "Dominant #9" => ["3 b7 #9", "b7 #9 3"],
      "Altered" => ["3 b7 #9", "b7 3 #5"],
      "Augmented 7" => ["3 #5 b7", "b7 3 #5"],
      "Dominant b5" => ["3 b5 b7", "b7 3 b5"],
      "Dominant 7 sus4" => ["4 b7 9", "b7 9 4"],
      "Dominant 9 sus4" => ["4 b7 9", "b7 9 4"],
      "Dominant 7 sus4 b9" => ["4 b7 b9", "b7 b9 4"],
      "Half Diminished" => ["b3 b5 b7", "b7 b3 b5"]
    })

    voice(family, "Diminished 7", "Shell I" => "b3 b5 bb7", "Shell II" => "bb7 b3 b5", "Shell III" => "b5 bb7 b3")
  end


  VoicingFamily.create!(:name => "4-Note Rootless (Type A/B)", :voicing_tones_count => 4, :rootless => true).tap do |family|
    # Type A has the 3rd on the bottom and Type B the 7th, with the 9th (or
    # another tension) in place of the root.
    voice_all(family, ["Type A", "Type B"], {
      "Major 7" => ["3 5 7 9", "7 9 3 5"],
      "Major 9" => ["3 5 7 9", "7 9 3 5"],
      "Major 7 #11" => ["3 #11 7 9", "7 9 3 #11"],
      "Major 7 #4#5" => ["3 #5 7 9", "7 9 3 #5"],
      "Major 6" => ["3 5 6 9", "6 9 3 5"],
      "Major 6/9" => ["3 5 6 9", "6 9 3 5"],
      "Minor 7" => ["b3 5 b7 9", "b7 9 b3 5"],
      "Minor 9" => ["b3 5 b7 9", "b7 9 b3 5"],
      "Minor 11" => ["b3 11 b7 9", "b7 9 b3 11"],
      "Minor 6" => ["b3 5 6 9", "6 9 b3 5"],
      "Minor b6" => ["b3 5 b6 9", "b6 9 b3 5"],
      "Minor-Major 7" => ["b3 5 7 9", "7 9 b3 5"],
      "Dominant 7" => ["3 5 b7 9", "b7 9 3 5"],
      "Dominant 9" => ["3 5 b7 9", "b7 9 3 5"],
      "Dominant 13" => ["3 13 b7 9", "b7 9 3 13"],
      "Dominant b9" => ["3 5 b7 b9", "b7 b9 3 5"],
      "Dominant #9" => ["3 5 b7 #9", "b7 #9 3 5"],
      "Dominant #11" => ["3 #11 b7 9", "b7 9 3 #11"],
      "Dominant b13" => ["3 b13 b7 9", "b7 9 3 b13"],
      "Altered" => ["3 #5 b7 #9", "b7 #9 3 #5"],
      "Augmented 7" => ["3 #5 b7 9", "b7 9 3 #5"],
      "Dominant b5" => ["3 b5 b7 9", "b7 9 3 b5"],
      "Dominant 7 sus4" => ["4 5 b7 9", "b7 9 4 5"],
      "Dominant 9 sus4" => ["4 5 b7 9", "b7 9 4 5"],
      "Dominant 7 sus4 b9" => ["4 5 b7 b9", "b7 b9 4 5"],
      # Natural 9 on a half-diminished chord, from Locrian #2.
      "Half Diminished" => ["b3 b5 b7 9", "b7 9 b3 b5"]
    })

    voice(family, "Diminished 7", "Type A" => "b3 b5 bb7 9", "Type B" => "bb7 9 b3 b5", "Type C" => "b5 bb7 9 b3")
  end


  VoicingFamily.create!(:name => "Drop 2", :voicing_tones_count => 4, :rootless => true).tap do |family|
    # Each inversion of the chord in close position with the second note from
    # the top dropped an octave, played over the root: Drop 2 I is C E G B
    # with the G dropped, G C E B.
    names = ["Drop 2 I", "Drop 2 II", "Drop 2 III", "Drop 2 IV"]

    VoicingSeeds::SEVENTH_CHORDS.merge("Diminished 7" => %w[u b3 b5 bb7]).each do |chord_name, tones|
      voicings = (0..3).map do |inversion|
        *lower, second, top = tones.rotate(inversion)
        [second, *lower, top].join(" ")
      end
      voice(family, chord_name, names.zip(voicings).to_h)
    end
  end


  VoicingFamily.create!(:name => "4-Note Shell Extensions", :voicing_tones_count => 4, :rootless => true)
  VoicingFamily.create!(:name => "5-Note Shell Extensions", :voicing_tones_count => 5, :rootless => true)

  VoicingFamily.create!(:name => "5-Note Quartal", :voicing_tones_count => 5, :rootless => false, :left_hand_tones_count => 3).tap do |family|
    # Three 4ths and a major 3rd, as Bill Evans voiced the Dorian chords of
    # "So What": D G C F A on Dm7, and E A D G B from the 9th. The left hand
    # takes the 4ths and the right hand the 4th and 3rd on top.
    ["Minor 7", "Minor 9", "Minor 11"].each do |chord_name|
      voice(family, chord_name, "So What I" => "u 11 b7 b3 5", "So What II" => "9 5 u 11 13")
    end
  end

  VoicingFamily.create!(:name => "6-Note Quartal", :voicing_tones_count => 6, :rootless => true)


  VoicingFamily.create!(:name => "Upper Structures", :voicing_tones_count => 5, :rootless => true, :left_hand_tones_count => 2).tap do |family|
    # A major triad in the right hand over the 3rd and 7th in the left, the
    # triad's notes the chord's tensions: on C7, Ab (the #5, root and #9 of
    # C7alt), Gb (b5, b7 and b9 of C7b9) or D (9, #11 and 13 of C7#11).
    {
      "Altered" => ["bVI", %w[b6 u b3]],
      "Dominant b9" => ["bV", %w[b5 b7 b9]],
      "Dominant #11" => ["II", %w[9 #11 13]]
    }.each do |chord_name, (numeral, triad)|
      voicings = {}
      {"3rd and 7th" => "3 b7", "7th and 3rd" => "b7 3"}.each do |shell, shell_tones|
        ["", ", 1st Inversion", ", 2nd Inversion"].each_with_index do |inversion, i|
          voicings["#{numeral} over #{shell}#{inversion}"] = [shell_tones, *triad.rotate(i)].join(" ")
        end
      end
      voice(family, chord_name, voicings)
    end
  end
end
