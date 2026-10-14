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

    it "returns nil for unknown symbols" do
      expect(described_class["Xyz"]).to be_nil
    end
  end
end
