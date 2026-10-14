VoicingFamily.create!(:name => "Triads", :voicing_tones_count => 3, :rootless => false).tap do |family|
  Chord.find_by_name("Major Triad").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Root Inversion", :specify_tones => "u 3 5")
    c.voicings.create!(:voicing_family => family, :name => "1st Inversion", :specify_tones => "3 5 u")
    c.voicings.create!(:voicing_family => family, :name => "2nd Inversion", :specify_tones => "5 u 3")
    c.voicings.create!(:voicing_family => family, :name => "Doubled Root", :specify_tones => "u 3 5 u")
  end

  Chord.find_by_name("Minor Triad").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Root Inversion", :specify_tones => "u m3 5")
    c.voicings.create!(:voicing_family => family, :name => "1st Inversion", :specify_tones => "m3 5 u")
    c.voicings.create!(:voicing_family => family, :name => "2nd Inversion", :specify_tones => "5 u m3")
    c.voicings.create!(:voicing_family => family, :name => "Doubled Root", :specify_tones => "u m3 5 u")
  end

  Chord.find_by_name("Diminished Triad").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Root Inversion", :specify_tones => "u m3 b5")
    c.voicings.create!(:voicing_family => family, :name => "1st Inversion", :specify_tones => "m3 b5 u")
    c.voicings.create!(:voicing_family => family, :name => "2nd Inversion", :specify_tones => "b5 u m3")
    c.voicings.create!(:voicing_family => family, :name => "Doubled Root", :specify_tones => "u m3 b5 u")
  end

  ["Major Triad", "Minor Triad", "Diminished Triad"].map { |n| Chord.find_by_name(n) }.combination(2).each do |pair|
    ["Root Inversion", "1st Inversion", "2nd inversion", "Doubled Root"].each do |voicing_name|
      VoiceLeading.define 0, pair[0].voicings.find_by_name(voicing_name), pair[1].voicings.find_by_name(voicing_name)
      VoiceLeading.define 0, pair[1].voicings.find_by_name(voicing_name), pair[0].voicings.find_by_name(voicing_name)
    end
  end
end


VoicingFamily.create!(:name => "4-Note Rooted", :voicing_tones_count => 4, :rootless => false).tap do |family|
  Chord.find_by_name("Major 7").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Rooted I", :specify_tones => "u 3 5 7")
    c.voicings.create!(:voicing_family => family, :name => "Rooted II", :specify_tones => "5 7 u 3")
  end

  Chord.find_by_name("Major 6").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Rooted I", :specify_tones => "u 3 5 6")
    c.voicings.create!(:voicing_family => family, :name => "Rooted II", :specify_tones => "5 6 u 3")
  end

  Chord.find_by_name("Minor 7").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Rooted I", :specify_tones => "u m3 5 m7")
    c.voicings.create!(:voicing_family => family, :name => "Rooted II", :specify_tones => "5 m7 u m3")
  end

  Chord.find_by_name("Minor 6").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Rooted I", :specify_tones => "u m3 5 6")
    c.voicings.create!(:voicing_family => family, :name => "Rooted II", :specify_tones => "5 6 u m3")
  end

  Chord.find_by_name("Minor b6").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Rooted I", :specify_tones => "u m3 5 b6")
    c.voicings.create!(:voicing_family => family, :name => "Rooted II", :specify_tones => "5 b6 u m3")
  end

  Chord.find_by_name("Major-Minor").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Rooted I", :specify_tones => "u m3 5 7")
    c.voicings.create!(:voicing_family => family, :name => "Rooted II", :specify_tones => "5 7 u m3")
  end

  Chord.find_by_name("Dominant 7").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Rooted I", :specify_tones => "u 3 5 m7")
    c.voicings.create!(:voicing_family => family, :name => "Rooted II", :specify_tones => "5 m7 u 3")
  end

  Chord.find_by_name("Dominant b5").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Rooted I", :specify_tones => "u 3 b5 m7")
    c.voicings.create!(:voicing_family => family, :name => "Rooted II", :specify_tones => "b5 m7 u 3")
  end

  Chord.find_by_name("Half Diminished").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Rooted I", :specify_tones => "u 3 b5 m7")
    c.voicings.create!(:voicing_family => family, :name => "Rooted II", :specify_tones => "b5 m7 u 3")
  end

  Chord.find_by_name("Full Diminished").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Rooted I", :specify_tones => "u 3 b5 6")
    c.voicings.create!(:voicing_family => family, :name => "Rooted II", :specify_tones => "3 b5 6 u")
    c.voicings.create!(:voicing_family => family, :name => "Rooted III", :specify_tones => "b5 6 u 3")
    c.voicings.create!(:voicing_family => family, :name => "Rooted IV", :specify_tones => "6 u 3 b5")
  end

  ["Major 7", "Major 6", "Minor 7", "Minor 6", "Minor b6", "Major-Minor", "Dominant 7", "Dominant b5", "Half Diminished"].map { |n| Chord.find_by_name(n) }.combination(2).each do |pair|
    ["Rooted I", "Rooted II"].each do |voicing_name|
      VoiceLeading.define 0, pair[0].voicings.find_by_name(voicing_name), pair[1].voicings.find_by_name(voicing_name)
      VoiceLeading.define 0, pair[1].voicings.find_by_name(voicing_name), pair[0].voicings.find_by_name(voicing_name)
    end

    VoiceLeading.define 5, pair[0].voicings.find_by_name("Rooted I"), pair[1].voicings.find_by_name("Rooted II")
    VoiceLeading.define 5, pair[1].voicings.find_by_name("Rooted I"), pair[0].voicings.find_by_name("Rooted II")
    VoiceLeading.define 5, pair[0].voicings.find_by_name("Rooted II"), pair[1].voicings.find_by_name("Rooted I")
    VoiceLeading.define 5, pair[1].voicings.find_by_name("Rooted II"), pair[0].voicings.find_by_name("Rooted I")
  end
end


VoicingFamily.create!(:name => "Guide Tones", :voicing_tones_count => 2, :rootless => true).tap do |family|
  Chord.find_by_name("Major 7").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Guide Tones I", :specify_tones => "3 7")
    c.voicings.create!(:voicing_family => family, :name => "Guide Tones II", :specify_tones => "7 3")
  end

  Chord.find_by_name("Major 6").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Guide Tones I", :specify_tones => "3 6")
    c.voicings.create!(:voicing_family => family, :name => "Guide Tones I", :specify_tones => "6 3")
  end

  Chord.find_by_name("Minor 7").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Guide Tones I", :specify_tones => "m3 m7")
    c.voicings.create!(:voicing_family => family, :name => "Guide Tones II", :specify_tones => "m7 m3")
  end

  Chord.find_by_name("Minor 6").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Guide Tones I", :specify_tones => "m3 6")
    c.voicings.create!(:voicing_family => family, :name => "Guide Tones II", :specify_tones => "6 m3")
  end

  Chord.find_by_name("Minor b6").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Guide Tones I", :specify_tones => "m3 b6")
    c.voicings.create!(:voicing_family => family, :name => "Guide Tones II", :specify_tones => "b6 m3")
  end

  Chord.find_by_name("Major-Minor").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Guide Tones I", :specify_tones => "m3 7")
    c.voicings.create!(:voicing_family => family, :name => "Guide Tones II", :specify_tones => "7 m3")
  end

  Chord.find_by_name("Dominant 7").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Guide Tones I", :specify_tones => "3 m7")
    c.voicings.create!(:voicing_family => family, :name => "Guide Tones II", :specify_tones => "m7 3")
  end

  ["Major 7", "Major 6", "Minor 7", "Minor 6", "Minor b6", "Major-Minor", "Dominant 7"].map { |n| Chord.find_by_name(n) }.combination(2).each do |pair|
    ["Guide Tones I", "Guide Tones II"].each do |voicing_name|
      VoiceLeading.define 0, pair[0].voicings.find_by_name(voicing_name), pair[1].voicings.find_by_name(voicing_name)
      VoiceLeading.define 0, pair[1].voicings.find_by_name(voicing_name), pair[0].voicings.find_by_name(voicing_name)
    end

    VoiceLeading.define 5, pair[0].voicings.find_by_name("Guide Tones I"), pair[1].voicings.find_by_name("Guide Tones II")
    VoiceLeading.define 5, pair[1].voicings.find_by_name("Guide Tones I"), pair[0].voicings.find_by_name("Guide Tones II")
    VoiceLeading.define 5, pair[0].voicings.find_by_name("Guide Tones II"), pair[1].voicings.find_by_name("Guide Tones I")
    VoiceLeading.define 5, pair[1].voicings.find_by_name("Guide Tones II"), pair[0].voicings.find_by_name("Guide Tones I")
  end
end


VoicingFamily.create!(:name => "Rooted Guide Tones", :voicing_tones_count => 3, :rootless => true).tap do |family|
  Chord.find_by_name("Major 7").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Rooted Guide Tones I", :specify_tones => "u 3 7")
    c.voicings.create!(:voicing_family => family, :name => "Rooted Guide Tones II", :specify_tones => "u 7 3")
  end

  Chord.find_by_name("Major 6").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Rooted Guide Tones I", :specify_tones => "u 3 6")
    c.voicings.create!(:voicing_family => family, :name => "Rooted Guide Tones II", :specify_tones => "u 6 3")
  end

  Chord.find_by_name("Minor 7").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Rooted Guide Tones I", :specify_tones => "u m3 m7")
    c.voicings.create!(:voicing_family => family, :name => "Rooted Guide Tones II", :specify_tones => "u m7 m3")
  end

  Chord.find_by_name("Minor 6").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Rooted Guide Tones I", :specify_tones => "u m3 6")
    c.voicings.create!(:voicing_family => family, :name => "Rooted Guide Tones II", :specify_tones => "u 6 m3")
  end

  Chord.find_by_name("Minor b6").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Rooted Guide Tones I", :specify_tones => "u m3 b6")
    c.voicings.create!(:voicing_family => family, :name => "Rooted Guide Tones II", :specify_tones => "u b6 m3")
  end

  Chord.find_by_name("Major-Minor").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Rooted Guide Tones I", :specify_tones => "u m3 7")
    c.voicings.create!(:voicing_family => family, :name => "Rooted Guide Tones II", :specify_tones => "u 7 m3")
  end

  Chord.find_by_name("Dominant 7").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Rooted Guide Tones I", :specify_tones => "u 3 m7")
    c.voicings.create!(:voicing_family => family, :name => "Rooted Guide Tones II", :specify_tones => "u m7 3")
  end

  ["Major 7", "Major 6", "Minor 7", "Minor 6", "Minor b6", "Major-Minor", "Dominant 7"].map { |n| Chord.find_by_name(n) }.combination(2).each do |pair|
    ["Rooted Guide Tones I", "Rooted Guide Tones II"].each do |voicing_name|
      VoiceLeading.define 0, pair[0].voicings.find_by_name(voicing_name), pair[1].voicings.find_by_name(voicing_name)
      VoiceLeading.define 0, pair[1].voicings.find_by_name(voicing_name), pair[0].voicings.find_by_name(voicing_name)
    end

    VoiceLeading.define 5, pair[0].voicings.find_by_name("Rooted Guide Tones I"), pair[1].voicings.find_by_name("Rooted Guide Tones II")
    VoiceLeading.define 5, pair[1].voicings.find_by_name("Rooted Guide Tones I"), pair[0].voicings.find_by_name("Rooted Guide Tones II")
    VoiceLeading.define 5, pair[0].voicings.find_by_name("Rooted Guide Tones II"), pair[1].voicings.find_by_name("Rooted Guide Tones I")
    VoiceLeading.define 5, pair[1].voicings.find_by_name("Rooted Guide Tones II"), pair[0].voicings.find_by_name("Rooted Guide Tones I")
  end
end


VoicingFamily.create!(:name => "Rootless 3-Note Shells", :voicing_tones_count => 3, :rootless => true).tap do |family|
  Chord.find_by_name("Major 7").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Shell I", :specify_tones => "3 7 9")
    c.voicings.create!(:voicing_family => family, :name => "Shell II", :specify_tones => "7 3 5")
  end

  Chord.find_by_name("Major 6").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Shell I", :specify_tones => "3 6 9")
    c.voicings.create!(:voicing_family => family, :name => "Shell II", :specify_tones => "6 9 5")
  end

  Chord.find_by_name("Minor 7").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Shell I", :specify_tones => "m3 m7 9")
    c.voicings.create!(:voicing_family => family, :name => "Shell II", :specify_tones => "m7 m3 5")
  end

  Chord.find_by_name("Minor 6").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Shell I", :specify_tones => "m3 6 9")
    c.voicings.create!(:voicing_family => family, :name => "Shell II", :specify_tones => "6 m3 5")
  end

  Chord.find_by_name("Minor b6").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Shell I", :specify_tones => "m3 b6 9")
    c.voicings.create!(:voicing_family => family, :name => "Shell II", :specify_tones => "b6 m3 5")
  end

  Chord.find_by_name("Major-Minor").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Shell I", :specify_tones => "m3 7 9")
    c.voicings.create!(:voicing_family => family, :name => "Shell II", :specify_tones => "7 m3 5")
  end

  Chord.find_by_name("Dominant 7").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Shell I", :specify_tones => "3 b7 9")
    c.voicings.create!(:voicing_family => family, :name => "Shell II", :specify_tones => "b7 3 5")
  end
  Chord.find_by_name("Dominant 9").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Shell I", :specify_tones => "3 b7 9")
  end
  Chord.find_by_name("Dominant 6/9").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Shell II", :specify_tones => "b7 3 6")
  end
  Chord.find_by_name("Dominant b9").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Shell I", :specify_tones => "3 b7 b9")
  end
  Chord.find_by_name("Dominant #9").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Shell I", :specify_tones => "3 b7 #9")
  end
  Chord.find_by_name("Altered").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Shell I", :specify_tones => "3 b7 #9")
    c.voicings.create!(:voicing_family => family, :name => "Shell II", :specify_tones => "b7 3 #5")
  end

  Chord.find_by_name("Dominant b5").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Shell II", :specify_tones => "b7 3 b5")
  end

  Chord.find_by_name("Half Diminished").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Shell II", :specify_tones => "b7 3 b5")
  end

  Chord.find_by_name("Full Diminished").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Shell I", :specify_tones => "3 b5 6")
    c.voicings.create!(:voicing_family => family, :name => "Shell II", :specify_tones => "3 b5 6")
    c.voicings.create!(:voicing_family => family, :name => "Shell III", :specify_tones => "b5 6 3")
    c.voicings.create!(:voicing_family => family, :name => "Shell IV", :specify_tones => "6 3 b5")
  end

  ["Major 7", "Major 6", "Minor 7", "Minor 6", "Minor b6", "Major-Minor", "Dominant 7", "Dominant 9", "Dominant #9", "Altered", "Dominant b5", "Half Diminished"].map do |n|
    Chord.find_by_name(n)
  end.combination(2).each do |pair|
    ["Shell I", "Shell II"].each do |voicing_name|
      VoiceLeading.define 0, pair[0].voicings.find_by_name(voicing_name), pair[1].voicings.find_by_name(voicing_name)
      VoiceLeading.define 0, pair[1].voicings.find_by_name(voicing_name), pair[0].voicings.find_by_name(voicing_name)
    end

    VoiceLeading.define 5, pair[0].voicings.find_by_name("Shell I"), pair[1].voicings.find_by_name("Shell II")
    VoiceLeading.define 5, pair[1].voicings.find_by_name("Shell I"), pair[0].voicings.find_by_name("Shell II")
    VoiceLeading.define 5, pair[0].voicings.find_by_name("Shell II"), pair[1].voicings.find_by_name("Shell I")
    VoiceLeading.define 5, pair[1].voicings.find_by_name("Shell II"), pair[0].voicings.find_by_name("Shell I")
  end
end


VoicingFamily.create!(:name => "4-Note Rootless (Type I/II)", :voicing_tones_count => 4, :rootless => true).tap do |family|
  Chord.find_by_name("Major 7").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Type I", :specify_tones => "3 5 7 9")
    c.voicings.create!(:voicing_family => family, :name => "Type II", :specify_tones => "7 9 3 5")
  end

  Chord.find_by_name("Major 6").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Type I", :specify_tones => "3 5 6 9")
    c.voicings.create!(:voicing_family => family, :name => "Type II", :specify_tones => "6 9 3 5")
  end

  Chord.find_by_name("Minor 7").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Type I", :specify_tones => "m3 5 m7 9")
    c.voicings.create!(:voicing_family => family, :name => "Type II", :specify_tones => "m7 9 m3 5")
  end

  Chord.find_by_name("Minor 6").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Type I", :specify_tones => "m3 5 6 9")
    c.voicings.create!(:voicing_family => family, :name => "Type II", :specify_tones => "6 9 m3 5")
  end

  Chord.find_by_name("Minor b6").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Type I", :specify_tones => "m3 5 b6 9")
    c.voicings.create!(:voicing_family => family, :name => "Type II", :specify_tones => "b6 9 m3 5")
  end

  Chord.find_by_name("Major-Minor").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Type I", :specify_tones => "m3 5 7 9")
    c.voicings.create!(:voicing_family => family, :name => "Type II", :specify_tones => "7 9 m3 5")
  end

  Chord.find_by_name("Dominant 7").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Type I", :specify_tones => "3 5 b7 9")
    c.voicings.create!(:voicing_family => family, :name => "Type II", :specify_tones => "b7 9 3 5")
  end
  Chord.find_by_name("Dominant 9").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Type I", :specify_tones => "3 5 b7 9")
    c.voicings.create!(:voicing_family => family, :name => "Type II", :specify_tones => "b7 9 3 5")
  end
  Chord.find_by_name("Dominant 6/9").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Type I", :specify_tones => "3 6 b7 9")
    c.voicings.create!(:voicing_family => family, :name => "Type II", :specify_tones => "b7 9 3 6")
  end
  Chord.find_by_name("Dominant b9").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Type I", :specify_tones => "3 5 b7 b9")
    c.voicings.create!(:voicing_family => family, :name => "Type II", :specify_tones => "b7 b9 3 5")
  end
  Chord.find_by_name("Dominant #9").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Type I", :specify_tones => "3 5 b7 #9")
    c.voicings.create!(:voicing_family => family, :name => "Type II", :specify_tones => "b7 #9 3 5")
  end
  Chord.find_by_name("Altered").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Type I", :specify_tones => "3 #5 b7 #9")
    c.voicings.create!(:voicing_family => family, :name => "Type II", :specify_tones => "b7 #9 3 #5")
  end

  Chord.find_by_name("Dominant b5").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Type I", :specify_tones => "3 b5 m7 9")
    c.voicings.create!(:voicing_family => family, :name => "Type II", :specify_tones => "m7 9 3 b5")
  end

  Chord.find_by_name("Half Diminished").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Type I", :specify_tones => "3 b5 m7 9")
    c.voicings.create!(:voicing_family => family, :name => "Type II", :specify_tones => "m7 9 3 b5")
  end

  Chord.find_by_name("Full Diminished").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Type I", :specify_tones => "3 b5 6 9")
    c.voicings.create!(:voicing_family => family, :name => "Type II", :specify_tones => "b5 6 9 3")
    c.voicings.create!(:voicing_family => family, :name => "Type III", :specify_tones => "6 9 3 b5")
  end

  ["Major 7", "Major 6", "Minor 7", "Minor 6", "Minor b6", "Major-Minor", "Dominant 7", "Dominant 9", "Dominant #9", "Altered", "Dominant b5", "Half Diminished"].map do |n|
    Chord.find_by_name(n)
  end.combination(2).each do |pair|
    ["Type I", "Type II"].each do |voicing_name|
      VoiceLeading.define 0, pair[0].voicings.find_by_name(voicing_name), pair[1].voicings.find_by_name(voicing_name)
      VoiceLeading.define 0, pair[1].voicings.find_by_name(voicing_name), pair[0].voicings.find_by_name(voicing_name)
    end

    VoiceLeading.define 5, pair[0].voicings.find_by_name("Type I"), pair[1].voicings.find_by_name("Type II")
    VoiceLeading.define 5, pair[1].voicings.find_by_name("Type I"), pair[0].voicings.find_by_name("Type II")
    VoiceLeading.define 5, pair[0].voicings.find_by_name("Type II"), pair[1].voicings.find_by_name("Type I")
    VoiceLeading.define 5, pair[1].voicings.find_by_name("Type II"), pair[0].voicings.find_by_name("Type I")
  end
end


VoicingFamily.create!(:name => "4-Note Shell Extensions", :voicing_tones_count => 4, :rootless => true).tap do |family|
  # TODO: Need Voicing Books
end


VoicingFamily.create!(:name => "5-Note Shell Extensions", :voicing_tones_count => 5, :rootless => true).tap do |family|
  # TODO: Need Voicing Books
end


VoicingFamily.create!(:name => "5-Note Quartal", :voicing_tones_count => 5, :rootless => true).tap do |family|
  # TODO: Need Voicing Books
end


VoicingFamily.create!(:name => "6-Note Quartal", :voicing_tones_count => 6, :rootless => true).tap do |family|
  # TODO: Need Voicing Books
end


VoicingFamily.create!(:name => "Upper Structures", :voicing_tones_count => 5, :rootless => true).tap do |family|
  # TODO: Need Voicing Books

  Chord.find_by_name("Altered").tap do |c|
    c.voicings.create!(:voicing_family => family, :name => "Dominant #5 Upper Structure I", :specify_tones => "3 b7 b6 u b3")
    c.voicings.create!(:voicing_family => family, :name => "Dominant #5 Upper Structure I 1st Inversion", :specify_tones => "3 b7 b3 b6 u")
    c.voicings.create!(:voicing_family => family, :name => "Dominant #5 Upper Structure II", :specify_tones => "b7 3 u b3 b6")
    c.voicings.create!(:voicing_family => family, :name => "Dominant #5 Upper Structure II 1st Inversion", :specify_tones => "b7 3 b3 b6 u")
  end
end
