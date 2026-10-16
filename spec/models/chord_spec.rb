RSpec.describe Chord, type: :model do
  context "associations" do
    it { should belong_to(:chord_quality) }
    it { should have_many(:chord_scales) }
    it { should have_many(:modes).through(:chord_scales) }
    it { should have_many(:voicings) }
  end

  context "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:chord_quality) }
  end

  it "should expose name as #to_s" do
    expect(Chord.new(:name => "Test").to_s).to eq("Test")
  end

  context "without key context" do
    subject { Chord.new(:name => "Test") }

    it "should expose #title as name" do
      expect(subject.title).to eq("Test")
    end
  end

  context "with key context" do
    subject { Chord.new(:name => "Test").in_key_of("Bb") }

    it "should expose #title as key and name" do
      expect(subject.title).to eq("Bb Test")
    end
  end

  describe ".resolve" do
    it "finds a chord from a symbol and places it in the symbol's key" do
      chord = described_class["Ebmaj7"]
      expect(chord.name).to eq("Major 7")
      expect(chord.key.name).to eq("Eb")
      expect(chord.notes).to eq(["Eb", "G", "Bb", "D"])
    end

    it "leaves the chord in C when no key is given" do
      expect(described_class["maj7"].notes).to eq(["C", "E", "G", "B"])
    end

    it "reads sharp and flat roots that start with another key's name" do
      expect(described_class["C#maj7"].notes).to eq(["C#", "E#", "G#", "B#"])
      expect(described_class["F#7"].key.name).to eq("F#")
      expect(described_class["Cbmaj7"].key.name).to eq("Cb")
    end

    it "returns nil for unknown symbols" do
      expect(described_class["Xyz"]).to be_nil
    end
  end

  describe "#lead_sheet_symbol" do
    it "writes minor as m and a major triad as its root" do
      expect(described_class["Dmin7"].lead_sheet_symbol).to eq("Dm7")
      expect(described_class["F#m7b5"].lead_sheet_symbol).to eq("F#m7b5")
      expect(described_class["Ebmaj7"].lead_sheet_symbol).to eq("Ebmaj7")
      expect(described_class["Gmaj"].lead_sheet_symbol).to eq("G")
      expect(described_class["Amin"].lead_sheet_symbol).to eq("Am")
    end
  end

  describe "#readable?" do
    it "says whether the chord can be spelled without double sharps or flats" do
      half_diminished = Chord.find_by!(name: "Half Diminished")

      expect(half_diminished.clone.in_key_of("C#")).to be_readable
      expect(half_diminished.clone.in_key_of("Db")).not_to be_readable
    end
  end

  describe "#degrees" do
    it "pairs each note with what it is to the root" do
      expect(described_class["Eb7"].degrees).to eq([["Eb", "root"], ["G", "major 3rd"], ["Bb", "5th"], ["Db", "minor 7th"]])
    end
  end

  describe "#guide_tones" do
    it "is the 3rd and 7th, or the 3rd and 6th of a 6th chord" do
      expect(described_class["Ebmaj9"].guide_tones).to eq([["G", "major 3rd"], ["D", "major 7th"]])
      expect(described_class["Fm6"].guide_tones).to eq([["Ab", "minor 3rd"], ["D", "6th"]])
    end

    it "is nil for a chord without both" do
      expect(described_class["C"].guide_tones).to be_nil
      expect(described_class["G7sus4"].guide_tones).to be_nil
    end
  end

  describe "#tritone_substitute" do
    it "is the dominant 7th a tritone away" do
      expect(described_class["Eb7"].tritone_substitute.short_name).to eq("A7")
      expect(described_class["G7alt"].tritone_substitute.short_name).to eq("Db7")
    end

    it "is nil for a chord that isn't a dominant" do
      expect(described_class["Dm7"].tritone_substitute).to be_nil
    end
  end

  describe "#roles" do
    it "finds the progressions the chord is played in, in the key that puts it there" do
      roles = described_class["Eb7"].roles.transform_values(&:title)

      expect(roles).to include("V7" => "Major ii-V Progression in Ab", "bII7" => "Tritone Sub ii-V-I Progression in D")
      expect(roles.values).to eq(roles.values.uniq)
    end

    it "spells the progression's key so the chord keeps its name" do
      described_class["F#m7"].roles.each_value do |progression|
        expect(progression.chords.map(&:short_name)).to include("F#m7")
      end
    end
  end
end
