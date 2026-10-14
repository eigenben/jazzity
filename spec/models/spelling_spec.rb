require "spec_helper"

# Every chord, voicing and progression should be spelled the way a player
# reads it in every key: each note named with the letter its interval calls
# for (the 3rd of E is G#, not Ab), and chord roots taken from the key.
RSpec.describe "Spelling in every key" do
  STANDARD_KEYS = %w[C Db D Eb E F F# Gb G Ab A Bb B].freeze

  def major_scale(key)
    Scale["Major"].in_key_of(key).notes
  end

  def progression_in(name, key)
    Progression[name].in_key_of(Key[key])
  end

  it "offers the twelve keys a jazz musician expects, with both F# and Gb" do
    expect(Key.standard.map(&:name)).to match_array(STANDARD_KEYS)
  end

  it "spells every note of every chord and voicing from its root's letter" do
    aggregate_failures do
      Key.searchable.each do |key|
        (Chord.all + Voicing.includes(:chord)).each do |toneable|
          toneable.in_key_of(key)
          notes = toneable.tones.keys

          toneable.tone_values.each_with_index do |value, i|
            index = (key.index + value["tone"]) % 12
            letter = (key.letter_index + value["letter_index"]) % 7
            message = "#{toneable.class} #{toneable} in #{key}: #{toneable.notes.join(' ')}"

            if Key.from_index(index, letter).double? && Tones::TENSION_LETTERS.include?(value["letter_index"])
              expect([notes[i].index, notes[i].double?]).to eq([index, false]), message
            else
              expect([notes[i].index, notes[i].letter_index]).to eq([index, letter]), message
            end
          end
        end
      end
    end
  end

  it "spells common chords as players write them" do
    {
      "Emaj7" => "E G# B D#", "B7" => "B D# F# A", "F#m7" => "F# A C# E", "Bbm7" => "Bb Db F Ab",
      "Dbmaj7" => "Db F Ab C", "Cm7b5" => "C Eb Gb Bb", "Bø7" => "B D F A", "Cdim7" => "C Eb Gb Bbb",
      "Ebdim7" => "Eb Gb Bbb Dbb", "C#o7" => "C# E G Bb", "G7#5" => "G B D# F", "C6/9" => "C E G A D",
      "C13" => "C E G Bb D A", "Ab7b9" => "Ab C Eb Gb A", "D7#9" => "D F# A C E#", "Gm(maj7)" => "G Bb D F#",
      "E7alt" => "E G# B# D F G", "Bb7#9" => "Bb D F Ab C#"
    }.each do |symbol, notes|
      expect(Chord[symbol].notes.join(" ")).to eq(notes), symbol
    end
  end

  it "writes Cb and B# in the octave they belong to" do
    expect(Chord["Abm"].octavized_notes).to eq(["Ab/3", "Cb/4", "Eb/4"])
    expect(Chord["G#maj"].octavized_notes).to eq(["G#/3", "B#/3", "D#/4"])
  end

  STANDARD_KEYS.each do |key|
    context "in #{key}" do
      it "spells the ii-V-I entirely within the key" do
        scale = major_scale(key)
        chords = progression_in("Major ii-V-I", key).chords

        expect(chords.map { |chord| chord.key.name }).to eq([scale[1], scale[4], scale[0]])
        chords.each { |chord| expect(scale).to include(*chord.notes), chord.title }
      end

      it "roots the minor ii-V-I on the same degrees" do
        scale = major_scale(key)
        chords = progression_in("Minor ii-V-I", key).chords

        expect(chords.map { |chord| chord.key.name }).to eq([scale[1], scale[4], scale[0]])
        expect(chords.map(&:name)).to eq(["Half Diminished", "Altered", "Minor 6"])
      end

      it "spells the blues from the key, flattening only the 3rd and 7th" do
        scale = major_scale(key)
        flats = [scale[2], scale[6]].map { |name| Key[name] }.map { |note| Key.from_index((note.index - 1) % 12, note.letter_index).name }
        chords = progression_in("Basic Blues", key).chords

        expect(chords.map { |chord| chord.key.name }.uniq).to eq([scale[0], scale[3], scale[4]])
        chords.each { |chord| expect(scale + flats).to include(*chord.notes), chord.title }
      end

      it "never roots a chord on a double sharp or flat, or on a flattened Cb or Fb" do
        Progression.all.each do |progression|
          progression.in_key_of(Key[key]).chords.each do |chord|
            expect(chord.key).not_to be_double, "#{progression} in #{key}: #{chord.short_name}"
          end
        end

        expect(progression_in("Chromatic b3-2-b2-I", key).chords.map { |chord| chord.key.name }).not_to include("Cb", "Fb")
      end

      it "spells every seeded progression as its chart says, from the key's letters" do
        scale = major_scale(key)

        aggregate_failures do
          Progression.includes(:components).find_each do |progression|
            progression.in_key_of(Key[key])
            numerals = progression.lead_sheet.numerals.to_a
            chords = progression.chords

            expect(progression.lead_sheet.chords.map(&:short_name)).to eq(chords.map(&:short_name)), progression.name
            numerals.zip(chords).each do |numeral, chord|
              message = "#{progression} in #{key}: #{numeral} is #{chord.short_name}"
              expect((chord.key.index - Key[key].index) % 12).to eq(numeral.index), message
              expect(chord.key).not_to be_double, message

              # A chord on a degree of the key whose notes are all in the key
              # is spelled with the key's own notes.
              in_scale = chord.notes.map { |note| Key[note].index }.all? { |index| scale.map { |note| Key[note].index }.include?(index) }
              expect(scale).to include(*chord.notes), message if numeral.accidental.zero? && numeral.of.nil? && in_scale
            end
          end
        end
      end
    end
  end

  it "spells progressions in sharp and flat keys from the key's letters" do
    expect(progression_in("Major ii-V-I", "E").chords.map(&:short_name)).to eq(%w[F#min7 B7 Emaj7])
    expect(progression_in("Major ii-V-I", "F#").chords.map(&:short_name)).to eq(%w[G#min7 C#7 F#maj7])
    expect(progression_in("Major ii-V-I", "Gb").chords.map(&:short_name)).to eq(%w[Abmin7 Db7 Gbmaj7])
    expect(progression_in("Minor ii-V-I", "A").chords.map(&:short_name)).to eq(%w[Bm7b5 E7alt Amin6])
    expect(progression_in("Chromatic b3-2-b2-I", "Db").chords.map(&:short_name)).to eq(%w[E7alt Ebmin7 D7alt Dbmaj7])
    expect(progression_in("Bebop Blues", "B").chords.map(&:short_name)).to include("E#dim7")
    expect(progression_in("Basic Blues", "Gb").chords.map(&:short_name).uniq).to eq(%w[Gb7 Cb7 Db7])
  end
end
