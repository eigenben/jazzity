require "spec_helper"

RSpec.describe ChordSequence do
  subject(:sequence) { described_class.new("Dm7 G7 Cmaj7") }

  it "accepts space or comma separated chord symbols" do
    expect(described_class.new("Dm7,G7, Cmaj7").chord_names).to eq(["Dm7", "G7", "Cmaj7"])
  end

  it "resolves each symbol into a chord in its key" do
    expect(sequence.chords.map(&:title)).to eq(["D Minor 7", "G Dominant 7", "C Major 7"])
  end

  it "keeps track of symbols it does not recognize" do
    expect(described_class.new("Dm7 Xyz").invalid_chords).to eq(["Xyz"])
  end

  it "is named and parameterized by its chord symbols" do
    expect(sequence.name).to eq("Dm7, G7, Cmaj7")
    expect(sequence.to_param).to eq("Dm7,G7,Cmaj7")
  end

  it "includes the key in its title when transposed" do
    expect(sequence.in_key_of("Bb").title).to eq("Dm7, G7, Cmaj7 in Bb")
  end

  it "measures the root movement between chords" do
    expect(sequence.chord_key_offsets).to eq([5, 5])
  end

  it "finds progressions with the same chords and root movement" do
    expect(sequence.progressions.map(&:title)).to eq(["Major ii-V-I Progression in C"])
  end

  it "names the key of a progression found in a sharp key" do
    expect(described_class.new("F#m7 B7 Emaj7").progressions.map(&:title)).to eq(["Major ii-V-I Progression in E"])
  end

  describe ".resolve" do
    it "returns a sequence of two or more recognized chords" do
      expect(described_class["Dm7 G7"]).to be_a(described_class)
    end

    it "returns nil for a single chord" do
      expect(described_class["Dm7"]).to be_nil
    end

    it "returns nil if any chord is unrecognized" do
      expect(described_class["Dm7 Xyz"]).to be_nil
    end
  end
end
