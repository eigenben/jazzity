# Each progression is written as a chart in roman numerals (see Chart):
# barlines between bars, the chords in a bar sharing it evenly, % to repeat
# the bar before, and labels such as A: and B: for the sections of a form.
# The chart is written out into components when the progression is saved.
ProgressionFamily.create!(:name => "Basic Progressions").tap do |family|
  family.progressions.create!(:name => "Major ii-V", :chart => "| ii7 | V7 |", :seeding => true, :full_tune => false,  :summary => "The building block of jazz harmony: a minor 7th chord on the 2nd degree moving up a fourth to the dominant 7th on the 5th.", :information => "")

  family.progressions.create!(:name => "Major ii-V-I", :chart => "| ii7 | V7 | Imaj7 |", :seeding => true, :full_tune => false,  :summary => "The most common cadence in jazz: a ii-V resolving to the major 7th tonic.", :information => "")

  family.progressions.create!(:name => "Minor ii-V", :chart => "| iiø7 | V7alt |", :seeding => true, :full_tune => false,  :summary => "The ii-V of a minor key: a half-diminished ii chord moving to an altered dominant, whose b9 and b13 are the 3rd and 6th of the minor key.", :information => "")

  family.progressions.create!(:name => "Minor ii-V-I", :chart => "| iiø7 | V7alt | i6 |", :seeding => true, :full_tune => false,  :summary => "The minor-key cadence, resolving to a minor 6th tonic: its major 6th comes from melodic minor, the usual scale on a minor i chord, and unlike a minor 7th it doesn't sound like another ii chord.", :information => "")
end


ProgressionFamily.create!(:name => "Turnarounds").tap do |family|
  family.progressions.create!(:name => "Major I-VI-ii-V", :chart => "| Imaj7 | VI7 | ii7 | V7 |", :seeding => true, :full_tune => false,  :summary => "The standard turnaround back to the top of a major tune, with VI7, the dominant of ii, in place of the diatonic vi chord.", :information => "")

  family.progressions.create!(:name => "Major iii-VI-ii-V", :chart => "| iii7 | VI7 | ii7 | V7 |", :seeding => true, :full_tune => false,  :summary => "The I-VI-ii-V turnaround with iii, which shares three notes with the I chord, standing in for the tonic.", :information => "")

  family.progressions.create!(:name => "Chromatic b3-2-b2-I", :chart => "| bIII7alt | ii7 | bII7alt | Imaj7 |", :seeding => true, :full_tune => false,  :summary => "The I-VI-ii-V turnaround with tritone substitutes for its dominants (bIII7 for VI7 and bII7 for V7), so the bass walks down by half steps to the tonic.", :information => "")
end


ProgressionFamily.create!(:name => "Blues").tap do |family|
  family.progressions.create!(:name => "Basic Blues", :chart => "| I7 | IV7 | I7 | % | IV7 | % | I7 | % | V7 | % | I7 | % |", :seeding => true, :full_tune => true, :meter => Meter["4/4"], :form => Form['A-B-C'], :summary => "The 12-bar blues in its simplest form, with dominant 7th chords on I, IV and V; the most commonly played progression in jazz.", :information => "").tap do |p|
    p.variants.create!(:progression_family => family, :name => "Blues with ii-V", :chart => "| I7 | IV7 | I7 | % | IV7 | % | I7 | % | ii7 | V7 | I7 | V7 |", :seeding => true, :full_tune => true, :meter => Meter["4/4"], :form => Form['A-B-C'], :summary => "The basic blues with a ii-V in bars 9 and 10 in place of V-IV, and a V7 turnaround in the last bar.")

    p.variants.create!(:progression_family => family, :name => "Jazz Blues", :chart => "| I7 | IV7 | I7 | % | IV7 | % | I7 | VI7 | ii7 | V7 | I7 | V7 |", :seeding => true, :full_tune => true, :meter => Meter["4/4"], :form => Form['A-B-C'], :summary => "A jazz blues: VI7 in bar 8 leads into a ii-V in bars 9 and 10, with a V7 turnaround in the last bar.")

    p.variants.create!(:progression_family => family, :name => "Bebop Blues", :chart => "| I7 | IV7 | I7 | v7 I7 | IV7 | #iv°7 | I7 | iiiø7 VI7 | ii7 | V7 | I7 VI7 | ii7 V7 |", :seeding => true, :full_tune => true, :meter => Meter["4/4"], :form => Form['A-B-C'], :summary => "A bebop blues: a ii-V into IV in bar 4, a #iv°7 passing chord in bar 6, a minor ii-V into ii in bar 8, and a I-VI-ii-V turnaround in the last two bars.")
  end
end

ProgressionFamily.create!(:name => "Rhythm Changes").tap do |family|
  a_section = "| I6 vi7 | ii7 V7 | I6 vi7 | ii7 V7 | I6 I7 | IV6 #iv°7 | I6 V7 | I6 |"
  bridge = "| III7 | % | VI7 | % | II7 | % | V7 | % |"

  family.progressions.create!(:name => "Original Rhythm Changes", :chart => "A: #{a_section}\nA: #{a_section}\nB: #{bridge}\nA: #{a_section}", :seeding => true, :full_tune => true, :meter => Meter["4/4"], :form => Form['A-A-B-A'],
    :summary => "The 32-bar A-A-B-A form of Gershwin's “I Got Rhythm”, the second most commonly played progression in jazz: I-vi-ii-V turnarounds in the A sections and a bridge of dominant 7ths around the cycle of fifths (III7, VI7, II7, V7).",
    :information => ""
  )
end
