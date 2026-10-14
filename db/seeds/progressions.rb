ProgressionFamily.create!(:name => "Basic Progressions").tap do |family|
  family.progressions.create!(:name => "Major ii-V", :seeding => true, :full_tune => false,  :summary => "The most commonly-used progression in Jazz.", :information => "").tap do |p|
    p.components.create([
      {:position => 1, :index => 2, :chord => Chord["min7"]},
      {:position => 2, :index => 7, :chord => Chord["7"]}
    ])
  end

  family.progressions.create!(:name => "Major ii-V-I", :seeding => true, :full_tune => false,  :summary => "The most commonly-used progression in Jazz.", :information => "").tap do |p|
    p.components.create([
      {:position => 1, :index => 2, :chord => Chord["min7"]},
      {:position => 2, :index => 7, :chord => Chord["7"]},
      {:position => 3, :index => 0, :chord => Chord["maj7"]}
    ])
  end

  family.progressions.create!(:name => "Minor ii-V", :seeding => true, :full_tune => false,  :summary => "The most commonly-used progression in Jazz.", :information => "").tap do |p|
    p.components.create([
      {:position => 1, :index => 2, :chord => Chord["dim7"]},
      {:position => 2, :index => 7, :chord => Chord["alt"]}
    ])
  end

  family.progressions.create!(:name => "Minor ii-V-I", :seeding => true, :full_tune => false,  :summary => "The most commonly-used progression in Jazz.", :information => "").tap do |p|
    p.components.create([
      {:position => 1, :index => 2, :chord => Chord["dim7"]},
      {:position => 2, :index => 7, :chord => Chord["alt"]},
      {:position => 3, :index => 0, :chord => Chord["min7"]}
    ])
  end
end


ProgressionFamily.create!(:name => "Turnarounds").tap do |family|
  family.progressions.create!(:name => "Major I-iv-ii-V", :seeding => true, :full_tune => false,  :summary => "A typical turn-around at the end of a major tune.", :information => "").tap do |p|
    p.components.create([
      {:position => 1, :index => 0, :chord => Chord["maj7"]},
      {:position => 2, :index => 9, :chord => Chord["7"]},
      {:position => 3, :index => 2, :chord => Chord["min7"]},
      {:position => 4, :index => 7, :chord => Chord["7"]}
    ])
  end

  family.progressions.create!(:name => "Major iii-iv-ii-V", :seeding => true, :full_tune => false,  :summary => "A typical turn-around at the end of a major tune.", :information => "").tap do |p|
    p.components.create([
      {:position => 1, :index => 4, :chord => Chord["min7"]},
      {:position => 2, :index => 9, :chord => Chord["7"]},
      {:position => 3, :index => 2, :chord => Chord["min7"]},
      {:position => 4, :index => 7, :chord => Chord["7"]}
    ])
  end

  family.progressions.create!(:name => "Chromatic b3-2-b2-I", :seeding => true, :full_tune => false,  :summary => "A typical turn-around at the end of a major tune.", :information => "").tap do |p|
    p.components.create([
      {:position => 1, :index => 3, :chord => Chord["7alt"]},
      {:position => 2, :index => 2, :chord => Chord["min7"]},
      {:position => 3, :index => 1, :chord => Chord["7alt"]},
      {:position => 4, :index => 0, :chord => Chord["maj7"]}
    ])
  end
end


ProgressionFamily.create!(:name => "Blues").tap do |family|
  family.progressions.create!(:name => "Basic Blues", :seeding => true, :bars => 12, :positions_per_bar => 2, :full_tune => true, :form => Form['A-B-C'], :summary => "The most commonly-played progression in Jazz, this 12-bar form has many variations.", :information => "").tap do |p|
    p.components.create([
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

    p.variants.create!(:progression_family => family, :name => "Blues 2", :seeding => true, :bars => 12, :positions_per_bar => 2, :full_tune => true, :form => Form['A-B-C']).tap do |pp|
      pp.components.create([
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

    p.variants.create!(:progression_family => family, :name => "Jazz Blues", :seeding => true, :bars => 12, :positions_per_bar => 2, :full_tune => true, :form => Form['A-B-C']).tap do |pp|
      pp.components.create([
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

    p.variants.create!(:progression_family => family, :name => "Blues 4", :seeding => true, :bars => 12, :positions_per_bar => 2, :full_tune => true, :form => Form['A-B-C']).tap do |pp|
      pp.components.create([
        {:position => 1, :index => 0, :chord => Chord["7"]},
        {:position => 3, :index => 5, :chord => Chord["7"]},
        {:position => 5, :index => 0, :chord => Chord["7"]},
        {:position => 7, :index => 0, :chord => Chord["7"]},
        {:position => 8, :index => 7, :chord => Chord["min7"]},
        {:position => 9, :index => 5, :chord => Chord["7"]},
        {:position => 11, :index => 5, :chord => Chord["7"]},
        {:position => 13, :index => 0, :chord => Chord["7"]},
        {:position => 15, :index => 4, :chord => Chord["dim7"]},
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
