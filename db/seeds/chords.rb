ChordQuality.create!(:name => 'Major', :code => 'MAJ').tap do |q|
  q.chords.create!(:name => 'Major Triad', :specify_tones => "u 3 5").tap do |c|
    c.symbols.create!(:name => 'maj', :primary => true)
    c.symbols.create!(:name => 'M', :case_sensitive => true)
    c.symbols.create!(:name => 'major')

    c.chord_scales << ChordScale.new(:mode => Scale['Major'].modes[0], :offset => 0)
  end

  q.chords.create!(:name => 'Major 7', :specify_tones => "u 3 5 7").tap do |c|
    c.symbols.create!(:name => 'maj7', :primary => true)
    c.symbols.create!(:name => 'M7', :case_sensitive => true)
    c.symbols.create!(:name => 'major7')

    c.children.create!(:chord_quality => q, :name => 'Major 7 #11', :specify_tones => "u 3 #4 5 7").tap do |cc|
      cc.symbols.create!(:name => 'maj7#11', :primary => true)
      cc.symbols.create!(:name => 'M7#11')
      cc.symbols.create!(:name => 'major7#11')
      cc.symbols.create!(:name => 'lyd')
      cc.symbols.create!(:name => 'lydian')

      cc.chord_scales << ChordScale.new(:mode => Scale['Major'].modes[3], :offset => -5)
    end

    c.children.create!(:chord_quality => q, :name => 'Major 7 #4#5', :specify_tones => "u 3 #4 #5 7").tap do |cc|
      cc.symbols.create!(:name => 'maj7#4#5', :primary => true)
      cc.symbols.create!(:name => 'lydaug')
      cc.symbols.create!(:name => 'maj7#11#5')

      cc.chord_scales << ChordScale.new(:mode => Scale['Melodic Minor'].modes[2], :offset => -3)
    end

    c.chord_scales << ChordScale.new(:mode => Scale['Major'].modes[0], :offset => 0)
  end

  q.chords.create!(:name => 'Major 6', :specify_tones => "u 3 5 6").tap do |c|
    c.symbols.create!(:name => '6', :primary => true)
    c.symbols.create!(:name => 'maj6')
    c.symbols.create!(:name => 'M6', :case_sensitive => true)
    c.symbols.create!(:name => 'major6')

    c.chord_scales << ChordScale.new(:mode => Scale['Pentatonic'].modes[0], :offset => 0)
    c.chord_scales << ChordScale.new(:mode => Scale['Major'].modes[0], :strength => 2, :offset => 0)
  end
end


ChordQuality.create!(:name => 'Minor', :code => 'MIN').tap do |q|
  q.chords.create!(:name => 'Minor Triad', :specify_tones => "u m3 5").tap do |c|
    c.symbols.create!(:name => 'min', :primary => true)
    c.symbols.create!(:name => 'm', :case_sensitive => true)
    c.symbols.create!(:name => '-')
    c.symbols.create!(:name => 'minor')

    c.chord_scales << ChordScale.new(:mode => Scale['Major'].modes[1], :offset => -2)
    c.chord_scales << ChordScale.new(:mode => Scale['Major'].modes[5], :strength => 2, :offset => 3)
    c.chord_scales << ChordScale.new(:mode => Scale['Major'].modes[2], :strength => 3, :offset => -4)
  end

  q.chords.create!(:name => 'Minor 7', :specify_tones => "u m3 5 b7").tap do |c|
    c.symbols.create!(:name => 'min7', :primary => true)
    c.symbols.create!(:name => 'm7', :case_sensitive => true)
    c.symbols.create!(:name => '-7')
    c.symbols.create!(:name => 'minor7')

    c.chord_scales << ChordScale.new(:mode => Scale['Major'].modes[1], :offset => -2)
    c.chord_scales << ChordScale.new(:mode => Scale['Major'].modes[5], :strength => 2, :offset => 3)
  end

  q.chords.create!(:name => 'Minor 6', :specify_tones => "u b3 5 6").tap do |c|
    c.symbols.create!(:name => 'min6', :primary => true)
    c.symbols.create!(:name => 'm6', :case_sensitive => true)
    c.symbols.create!(:name => '-6')
    c.symbols.create!(:name => 'minor6')

    c.chord_scales << ChordScale.new(:mode => Scale['Major'].modes[1], :offset => -2)
    c.chord_scales << ChordScale.new(:mode => Scale['Major'].modes[5], :strength => 2, :offset => 3)
  end

  q.chords.create!(:name => 'Phrygian', :specify_tones => "u b2 b3 5 b6").tap do |c|
    c.symbols.create!(:name => 'phryg', :primary => true)
    c.symbols.create!(:name => 'minb2')
    c.symbols.create!(:name => 'mb2')
    c.symbols.create!(:name => 'minorb2')
    c.symbols.create!(:name => 'phrygian')
    c.symbols.create!(:name => 'susb9')

    c.chord_scales << ChordScale.new(:mode => Scale['Major'].modes[2], :offset => -4)
  end

  q.chords.create!(:name => 'Minor b6', :specify_tones => "u b3 5 b6").tap do |c|
    c.symbols.create!(:name => 'minb6', :primary => true)
    c.symbols.create!(:name => 'mb6', :case_sensitive => true)
    c.symbols.create!(:name => '-b6')
    c.symbols.create!(:name => 'minorb6')
    c.symbols.create!(:name => 'aeolian')

    c.chord_scales << ChordScale.new(:mode => Scale['Major'].modes[5], :offset => 3)
  end

  q.chords.create!(:name => 'Major-Minor', :specify_tones => "u b3 5 7").tap do |c|
    c.symbols.create!(:name => 'min#7', :primary => true)
    c.symbols.create!(:name => 'majmin')
    c.symbols.create!(:name => 'm#7', :case_sensitive => true)
    c.symbols.create!(:name => '-#7')
    c.symbols.create!(:name => 'minor#7')

    c.chord_scales << ChordScale.new(:mode => Scale['Melodic Minor'].modes[0], :offset => 0)
  end
end


ChordQuality.create!(:name => 'Dominant', :code => 'DOM').tap do |q|
  q.chords.create!(:name => 'Dominant 7', :specify_tones => "u 3 5 b7").tap do |c|
    c.symbols.create!(:name => '7', :primary => true)
    c.symbols.create!(:name => 'dom')

    c.chord_scales << ChordScale.new(:mode => Scale['Major'].modes[4], :offset => 5)

    c.children.create!(:chord_quality => q, :name => 'Dominant 9', :specify_tones => "u 3 5 b7 2").tap do |cc|
      cc.symbols.create!(:name => '9', :primary => true)
      cc.symbols.create!(:name => 'dom9')

      cc.chord_scales << ChordScale.new(:mode => Scale['Major'].modes[4], :offset => 5)
    end

    c.children.create!(:chord_quality => q, :name => 'Dominant 6/9', :specify_tones => "u 3 5 6 b7 2").tap do |cc|
      cc.symbols.create!(:name => '6/9', :primary => true)
      cc.symbols.create!(:name => '69')

      cc.chord_scales << ChordScale.new(:mode => Scale['Major'].modes[4], :offset => 5)
      cc.chord_scales << ChordScale.new(:mode => Scale['Major'].modes[0], :offset => 0)
    end

    c.children.create!(:chord_quality => q, :name => 'Dominant b9', :specify_tones => "u 3 5 b7 b2").tap do |cc|
      cc.symbols.create!(:name => '7b9', :primary => true)

      cc.chord_scales << ChordScale.new(:mode => Scale['Diminished'].modes[0], :offset => 0)
      cc.chord_scales << ChordScale.new(:mode => Scale['Major'].modes[4], :strength => 2, :offset => 5)
    end

    c.children.create!(:chord_quality => q, :name => 'Dominant #9', :specify_tones => "u 3 5 b7 #2").tap do |cc|
      cc.symbols.create!(:name => '7#9', :primary => true)

      cc.chord_scales << ChordScale.new(:mode => Scale['Melodic Minor'].modes[6], :offset => 1)
      cc.chord_scales << ChordScale.new(:mode => Scale['Diminished'].modes[0], :strength => 2, :offset => 0)
    end

    c.children.create!(:chord_quality => q, :name => 'Dominant #11', :specify_tones => "u 3 5 b7 #4").tap do |cc|
      cc.symbols.create!(:name => '7#11', :primary => true)
      cc.symbols.create!(:name => 'lyd7')
      cc.symbols.create!(:name => 'lydiandom')

      cc.chord_scales << ChordScale.new(:mode => Scale['Melodic Minor'].modes[3], :offset => -5)
    end

    c.children.create!(:chord_quality => q, :name => 'Mixoylidian b6', :specify_tones => "u 3 5 b6 b7").tap do |cc|
      cc.symbols.create!(:name => '7b6', :primary => true)

      cc.chord_scales << ChordScale.new(:mode => Scale['Melodic Minor'].modes[4], :offset => 5)
    end

    c.children.create!(:chord_quality => q, :name => 'Altered', :specify_tones => "u 3 #5 b7 b2 #2").tap do |cc|
      cc.symbols.create!(:name => '7alt', :primary => true)
      cc.symbols.create!(:name => '7altered')
      cc.symbols.create!(:name => 'alt')
      cc.symbols.create!(:name => 'altered')
      cc.symbols.create!(:name => '7#9#5')
      cc.symbols.create!(:name => '7#5#9')
      cc.symbols.create!(:name => '7b9#9')
      cc.symbols.create!(:name => '7#9b9')
      cc.symbols.create!(:name => '7#5')

      cc.chord_scales << ChordScale.new(:mode => Scale['Melodic Minor'].modes[6], :offset => 1)
    end

    c.children.create!(:chord_quality => q, :name => 'Dominant b5', :specify_tones => "u 3 b5 b7").tap do |cc|
      cc.symbols.create!(:name => '7b5', :primary => true)

      cc.chord_scales << ChordScale.new(:mode => Scale['Melodic Minor'].modes[3], :offset => -5)
    end
  end
end


ChordQuality.create!(:name => 'Diminished', :code => 'DIM').tap do |q|
  q.chords.create!(:name => 'Diminished Triad', :specify_tones => "u b3 b5").tap do |c|
    c.symbols.create!(:name => 'dim', :primary => true)
    c.symbols.create!(:name => 'b5')

    c.chord_scales << ChordScale.new(:mode => Scale['Diminished'].modes[0], :offset => 0)
    c.chord_scales << ChordScale.new(:mode => Scale['Diminished'].modes[1], :offset => 0)
  end

  q.chords.create!(:name => 'Half Diminished', :specify_tones => "u b3 b5 b7").tap do |c|
    c.symbols.create!(:name => 'dim7', :primary => true)
    c.symbols.create!(:name => '7b5')

    c.chord_scales << ChordScale.new(:mode => Scale['Major'].modes[6], :offset => 1)
    c.chord_scales << ChordScale.new(:mode => Scale['Melodic Minor'].modes[5], :offset => 1)
  end

  q.chords.create!(:name => 'Full Diminished', :specify_tones => "u b3 b5 b7").tap do |c|
    c.symbols.create!(:name => 'fulldim', :primary => true)
    c.symbols.create!(:name => 'b5bb7')

    c.chord_scales << ChordScale.new(:mode => Scale['Diminished'].modes[0], :offset => 0)
    c.chord_scales << ChordScale.new(:mode => Scale['Diminished'].modes[1], :offset => 0)
  end
end
