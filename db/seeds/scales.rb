Scale.create!(:name => 'Major', :specify_tones => "u 2 3 4 5 6 7", :information => "The major scale and its modes are the most commonly used scales in western music.").tap do |s|
  s.modes.create!(:mode => 1, :name => 'Ionian')
  s.modes.create!(:mode => 2, :name => 'Dorian')
  s.modes.create!(:mode => 3, :name => 'Phrygian')
  s.modes.create!(:mode => 4, :name => 'Lydian')
  s.modes.create!(:mode => 5, :name => 'Mixolydian')
  s.modes.create!(:mode => 6, :name => 'Aeolian')
  s.modes.create!(:mode => 7, :name => 'Locrian')
end

Scale.create!(:name => 'Melodic Minor', :specify_tones => "u 2 m3 4 5 6 7", :information => "The melodic minor scale is similar to the major scale with only one difference - it uses a minor third instead of a major third.").tap do |s|
  s.modes.create!(:mode => 1, :name => 'Melodic Minor')
  s.modes.create!(:mode => 2, :name => 'Phrygian #6', :synonyms => 'Dorian b2')
  s.modes.create!(:mode => 3, :name => 'Lydian Augmented')
  s.modes.create!(:mode => 4, :name => 'Lydian Dominant', :synonyms => 'Mixolydian #4')
  s.modes.create!(:mode => 5, :name => 'Mixolydian b6')
  s.modes.create!(:mode => 6, :name => 'Locrian #2', :synonyms => 'Aeolian b5')
  s.modes.create!(:mode => 7, :name => 'Super Locrian', :synonyms => 'Diminished Whole Tone')
end

Scale.create!(:name => 'Whole Tone', :specify_tones => "u 2 3 #4 #5 b7", :symmetry_index => 2, :information => "The whole tone scale is in open, suspended harmony and works well with #5 chords.").tap do |s|
  s.modes.create!(:mode => 1, :name => 'Whole Tone')
end

Scale.create!(:name => 'Pentatonic', :specify_tones => "u 2 3 5 6", :information => "The major pentatonic scale leaves the 4th and 7th out of the major scale, so it has no half steps and no avoid notes; it is the sound of the black keys on the piano.").tap do |s|
  s.modes.create!(:mode => 1, :name => 'Pentatonic')
end

Scale.create!(:name => 'Blues', :specify_tones => "u 2 b3 3 5 6", :information => "The blues scale is used pervasively in jazz, and works especially well over the most common progression in jazz, the blues. Its major form adds a b3 to the major pentatonic scale; started from the 6th it becomes the minor blues scale, the minor pentatonic with an added b5.").tap do |s|
  s.modes.create!(:mode => 1, :name => 'Major Blues')
  s.modes.create!(:mode => 6, :name => "Minor Blues")
end

Scale.create!(:name => 'Diminished', :specify_tones => "u b2 b3 3 #4 5 6 b7", :symmetry_index => 3, :information => "The diminished scale alternates whole steps and half steps to produce a symmetric scale with some interesting attributes.").tap do |s|
  s.modes.create!(:mode => 1, :name => 'Half-Whole')
  s.modes.create!(:mode => 2, :name => 'Whole-Half')
end

Scale.create!(:name => 'Harmonic Minor', :specify_tones => "u 2 b3 4 5 b6 7", :information => "The harmonic minor scale raises the 7th of the natural minor scale. Jazz players use it over a minor tonic, and its 5th mode, Phrygian Dominant, is the classic sound of the V7b9 in a minor key.").tap do |s|
  s.modes.create!(:mode => 1, :name => "Harmonic Minor")
  s.modes.create!(:mode => 2, :name => "Locrian #6")
  s.modes.create!(:mode => 3, :name => "Ionian #5")
  s.modes.create!(:mode => 4, :name => "Dorian #4", :synonyms => "Ukrainian Dorian")
  s.modes.create!(:mode => 5, :name => "Phrygian Dominant", :synonyms => "Mixolydian b9 b13, Spanish Phrygian")
  s.modes.create!(:mode => 6, :name => "Lydian #2")
  s.modes.create!(:mode => 7, :name => "Altered Diminished", :synonyms => "Ultralocrian, Super Locrian bb7")
end

Scale.create!(:name => "Dominant Bebop", :specify_tones => "u 2 3 4 5 6 b7 7", :information => "The dominant bebop scale adds a major 7th passing tone to the Mixolydian mode, so that a run of eighth notes starting on a chord tone lands on chord tones on every beat.").tap do |s|
  s.modes.create!(:mode => 1, :name => "Dominant Bebop")
end

Scale.create!(:name => "Major Bebop", :specify_tones => "u 2 3 4 5 #5 6 7", :information => "The major bebop scale adds a #5 passing tone to the major scale, so that a run of eighth notes starting on a chord tone lands on the notes of a major 6th chord on every beat.").tap do |s|
  s.modes.create!(:mode => 1, :name => "Major Bebop")
end
