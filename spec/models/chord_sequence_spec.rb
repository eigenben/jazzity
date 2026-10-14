require "spec_helper"

RSpec.describe ChordSequence do
  subject(:sequence) { described_class.new("Dm7 G7 Cmaj7") }

  it "accepts chord symbols separated by spaces, commas, barlines or dashes" do
    ["Dm7,G7, Cmaj7", "Dm7 | G7 | Cmaj7", "Dm7-G7-Cmaj7", "Dm7 / G7 / Cmaj7"].each do |text|
      expect(described_class.new(text).chord_names).to eq(["Dm7", "G7", "Cmaj7"]), text
    end
  end

  it "keeps the dash of a minor chord" do
    expect(described_class.new("C-7-F7").chord_names).to eq(["C-7", "F7"])
  end

  it "reads bare roots as major triads and other spellings of chords" do
    expect(described_class.new("Dm7 G7 C").chords.map(&:title)).to eq(["D Minor 7", "G Dominant 7", "C Major Triad"])
    expect(described_class.new("D-7 G7(b9) C^7").chord_names).to eq(["D-7", "G7b9", "Cmaj7"])
  end

  it "needs a root for every chord" do
    expect(described_class.new("Dm7 maj7").invalid_chords).to eq(["maj7"])
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

  it "moves every chord into another key, keeping its degree" do
    transposed = sequence.in_key_of("Bb")
    expect(transposed.name).to eq("Cm7, F7, Bbmaj7")
    expect(transposed.title).to eq("Cm7, F7, Bbmaj7 in Bb")
    expect(transposed.to_param).to eq("Cm7,F7,Bbmaj7")
    expect(sequence.in_key_of("E").name).to eq("F#m7, B7, Emaj7")
  end

  it "transposes from the key it is in rather than from C" do
    expect(described_class.new("Em7 A7 Dmaj7").in_key_of("C").name).to eq("Dm7, G7, Cmaj7")
  end

  it "finds its home key from a known progression or its last chord" do
    expect(sequence.home_key.name).to eq("C")
    expect(described_class.new("Em7 A7 Dm7 G7").home_key.name).to eq("C")
    expect(described_class.new("Gm7 C7 F").home_key.name).to eq("F")
    expect(described_class.new("Am7 D7").home_key.name).to eq("G")
  end

  it "measures the root movement between chords" do
    expect(sequence.chord_key_offsets).to eq([5, 5])
  end

  it "finds progressions with the same chords and root movement" do
    expect(sequence.progressions.map(&:title)).to eq(["Major ii-V-I Progression in C"])
  end

  it "finds progressions whose chords are of the same kinds" do
    expect(described_class.new("Dm7 G7 C").progressions.map(&:title)).to eq(["Major ii-V-I Progression in C"])
    expect(described_class.new("Dm7 G7 Cm7").progressions).to be_empty
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
