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
end
