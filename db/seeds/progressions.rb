ProgressionFamily.create!(:name => "Basic Progressions").tap do |family|
  family.progressions.create!(:name => "Major ii-V", :seeding => true, :full_tune => false,  :summary => "The building block of jazz harmony: a minor 7th chord on the 2nd degree moving up a fourth to the dominant 7th on the 5th.", :information => "").tap do |p|
    p.components.create!([
      {:position => 1, :index => 2, :chord => Chord["min7"]},
      {:position => 2, :index => 7, :chord => Chord["7"]}
    ])
  end

  family.progressions.create!(:name => "Major ii-V-I", :seeding => true, :full_tune => false,  :summary => "The most common cadence in jazz: a ii-V resolving to the major 7th tonic.", :information => "").tap do |p|
    p.components.create!([
      {:position => 1, :index => 2, :chord => Chord["min7"]},
      {:position => 2, :index => 7, :chord => Chord["7"]},
      {:position => 3, :index => 0, :chord => Chord["maj7"]}
    ])
  end

  family.progressions.create!(:name => "Minor ii-V", :seeding => true, :full_tune => false,  :summary => "The ii-V of a minor key: a half-diminished ii chord moving to an altered dominant, whose b9 and b13 are the 3rd and 6th of the minor key.", :information => "").tap do |p|
    p.components.create!([
      {:position => 1, :index => 2, :chord => Chord["m7b5"]},
      {:position => 2, :index => 7, :chord => Chord["alt"]}
    ])
  end

  family.progressions.create!(:name => "Minor ii-V-I", :seeding => true, :full_tune => false,  :summary => "The minor-key cadence, resolving to a minor 6th tonic: its major 6th comes from melodic minor, the usual scale on a minor i chord, and unlike a minor 7th it doesn't sound like another ii chord.", :information => "").tap do |p|
    p.components.create!([
      {:position => 1, :index => 2, :chord => Chord["m7b5"]},
      {:position => 2, :index => 7, :chord => Chord["alt"]},
      {:position => 3, :index => 0, :chord => Chord["min6"]}
    ])
  end
end


ProgressionFamily.create!(:name => "Turnarounds").tap do |family|
  family.progressions.create!(:name => "Major I-VI-ii-V", :seeding => true, :full_tune => false,  :summary => "The standard turnaround back to the top of a major tune, with VI7, the dominant of ii, in place of the diatonic vi chord.", :information => "").tap do |p|
    p.components.create!([
      {:position => 1, :index => 0, :chord => Chord["maj7"]},
      {:position => 2, :index => 9, :chord => Chord["7"]},
      {:position => 3, :index => 2, :chord => Chord["min7"]},
      {:position => 4, :index => 7, :chord => Chord["7"]}
    ])
  end

  family.progressions.create!(:name => "Major iii-VI-ii-V", :seeding => true, :full_tune => false,  :summary => "The I-VI-ii-V turnaround with iii, which shares three notes with the I chord, standing in for the tonic.", :information => "").tap do |p|
    p.components.create!([
      {:position => 1, :index => 4, :chord => Chord["min7"]},
      {:position => 2, :index => 9, :chord => Chord["7"]},
      {:position => 3, :index => 2, :chord => Chord["min7"]},
      {:position => 4, :index => 7, :chord => Chord["7"]}
    ])
  end

  family.progressions.create!(:name => "Chromatic b3-2-b2-I", :seeding => true, :full_tune => false,  :summary => "The I-VI-ii-V turnaround with tritone substitutes for its dominants (bIII7 for VI7 and bII7 for V7), so the bass walks down by half steps to the tonic.", :information => "").tap do |p|
    p.components.create!([
      {:position => 1, :index => 3, :chord => Chord["7alt"]},
      {:position => 2, :index => 2, :chord => Chord["min7"]},
      {:position => 3, :index => 1, :chord => Chord["7alt"]},
      {:position => 4, :index => 0, :chord => Chord["maj7"]}
    ])
  end
end


ProgressionFamily.create!(:name => "Blues").tap do |family|
  family.progressions.create!(:name => "Basic Blues", :seeding => true, :bars => 12, :positions_per_bar => 2, :full_tune => true, :meter => Meter["4/4"], :form => Form['A-B-C'], :summary => "The 12-bar blues in its simplest form, with dominant 7th chords on I, IV and V; the most commonly played progression in jazz.", :information => "").tap do |p|
    p.components.create!([
      {:position => 1, :index => 0, :chord => Chord["7"]},
      {:position => 3, :index => 5, :chord => Chord["7"]},
      {:position => 5, :index => 0, :chord => Chord["7"]},
      {:position => 7, :index => 0, :chord => Chord["7"]},
      {:position => 9, :index => 5, :chord => Chord["7"]},
      {:position => 11, :index => 5, :chord => Chord["7"]},
      {:position => 13, :index => 0, :chord => Chord["7"]},
      {:position => 15, :index => 0, :chord => Chord["7"]},
      {:position => 17, :index => 7, :chord => Chord["7"]},
      {:position => 19, :index => 7, :chord => Chord["7"]},
      {:position => 21, :index => 0, :chord => Chord["7"]},
      {:position => 23, :index => 0, :chord => Chord["7"]}
    ])

    p.variants.create!(:progression_family => family, :name => "Blues with ii-V", :seeding => true, :bars => 12, :positions_per_bar => 2, :full_tune => true, :meter => Meter["4/4"], :form => Form['A-B-C'], :summary => "The basic blues with a ii-V in bars 9 and 10 in place of V-IV, and a V7 turnaround in the last bar.").tap do |pp|
      pp.components.create!([
        {:position => 1, :index => 0, :chord => Chord["7"]},
        {:position => 3, :index => 5, :chord => Chord["7"]},
        {:position => 5, :index => 0, :chord => Chord["7"]},
        {:position => 7, :index => 0, :chord => Chord["7"]},
        {:position => 9, :index => 5, :chord => Chord["7"]},
        {:position => 11, :index => 5, :chord => Chord["7"]},
        {:position => 13, :index => 0, :chord => Chord["7"]},
        {:position => 15, :index => 0, :chord => Chord["7"]},
        {:position => 17, :index => 2, :chord => Chord["min7"]},
        {:position => 19, :index => 7, :chord => Chord["7"]},
        {:position => 21, :index => 0, :chord => Chord["7"]},
        {:position => 23, :index => 7, :chord => Chord["7"]}
      ])
    end

    p.variants.create!(:progression_family => family, :name => "Jazz Blues", :seeding => true, :bars => 12, :positions_per_bar => 2, :full_tune => true, :meter => Meter["4/4"], :form => Form['A-B-C'], :summary => "A jazz blues: VI7 in bar 8 leads into a ii-V in bars 9 and 10, with a V7 turnaround in the last bar.").tap do |pp|
      pp.components.create!([
        {:position => 1, :index => 0, :chord => Chord["7"]},
        {:position => 3, :index => 5, :chord => Chord["7"]},
        {:position => 5, :index => 0, :chord => Chord["7"]},
        {:position => 7, :index => 0, :chord => Chord["7"]},
        {:position => 9, :index => 5, :chord => Chord["7"]},
        {:position => 11, :index => 5, :chord => Chord["7"]},
        {:position => 13, :index => 0, :chord => Chord["7"]},
        {:position => 15, :index => 9, :chord => Chord["7"]},
        {:position => 17, :index => 2, :chord => Chord["min7"]},
        {:position => 19, :index => 7, :chord => Chord["7"]},
        {:position => 21, :index => 0, :chord => Chord["7"]},
        {:position => 23, :index => 7, :chord => Chord["7"]}
      ])
    end

    p.variants.create!(:progression_family => family, :name => "Bebop Blues", :seeding => true, :bars => 12, :positions_per_bar => 2, :full_tune => true, :meter => Meter["4/4"], :form => Form['A-B-C'], :summary => "A bebop blues: a ii-V into IV in bar 4, a #iv°7 passing chord in bar 6, a minor ii-V into ii in bar 8, and a I-VI-ii-V turnaround in the last two bars.").tap do |pp|
      pp.components.create!([
        {:position => 1, :index => 0, :chord => Chord["7"]},
        {:position => 3, :index => 5, :chord => Chord["7"]},
        {:position => 5, :index => 0, :chord => Chord["7"]},
        {:position => 7, :index => 7, :chord => Chord["min7"]},
        {:position => 8, :index => 0, :chord => Chord["7"]},
        {:position => 9, :index => 5, :chord => Chord["7"]},
        {:position => 11, :index => 6, :degree => 4, :chord => Chord["dim7"]},
        {:position => 13, :index => 0, :chord => Chord["7"]},
        {:position => 15, :index => 4, :chord => Chord["m7b5"]},
        {:position => 16, :index => 9, :chord => Chord["7"]},
        {:position => 17, :index => 2, :chord => Chord["min7"]},
        {:position => 19, :index => 7, :chord => Chord["7"]},
        {:position => 21, :index => 0, :chord => Chord["7"]},
        {:position => 22, :index => 9, :chord => Chord["7"]},
        {:position => 23, :index => 2, :chord => Chord["min7"]},
        {:position => 24, :index => 7, :chord => Chord["7"]}
      ])
    end
  end
end

ProgressionFamily.create(:name => "Rhythm Changes").tap do |family|
  family.progressions.create!(:name => "Original Rhythm Changes", :seeding => true, :bars => 32, :full_tune => true, :form => Form['A-A-B-A'],
    :summary => "The second most commonly-played progression in Jazz, this A-A-B-A progression borrows from the famous tune, I've Got Rhythm.",
    :information => ""
  )
end
