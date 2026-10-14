require "spec_helper"

RSpec.describe Key, type: :model do
  it "should expose #to_s as name" do
    expect(described_class["Eb"].to_s).to eq("Eb")
  end

  it "should expose #default as the key of C" do
    expect(described_class.default.name).to eq("C")
  end

  it "should expose primary keys around the cycle" do
    expect(described_class.primaries.map(&:name)).to match(["C", "F", "Bb", "Eb", "Ab", "Db", "Gb", "B", "E", "A", "D", "G"])
  end

  describe "#enharmonic_with?" do
    it "should be true for keys that sound the same" do
      expect(described_class["Eb"]).to be_enharmonic_with(described_class["D#"])
    end

    it "should be false for different pitches" do
      expect(described_class["Eb"]).not_to be_enharmonic_with(described_class["E"])
    end
  end

  it "should offer the standard keys, with F# alongside Gb" do
    expect(described_class.standard.map(&:name)).to eq(["C", "F", "Bb", "Eb", "Ab", "Db", "Gb", "F#", "B", "E", "A", "D", "G"])
  end

  it "should make C# searchable too" do
    expect(described_class.searchable.map(&:name)).to include("F#", "C#")
  end

  describe "#shifted" do
    it "should move up by semitones, wrapping around the octave" do
      expect(described_class["C"].shifted(2).name).to eq("D")
      expect(described_class["Bb"].shifted(3).name).to eq("Db")
    end

    it "should spell the degree it lands on from the key's letter" do
      expect(described_class["E"].shifted(2).name).to eq("F#")
      expect(described_class["E"].shifted(7).name).to eq("B")
      expect(described_class["Gb"].shifted(5).name).to eq("Cb")
      expect(described_class["F#"].shifted(7).name).to eq("C#")
      expect(described_class["Ab"].shifted(-2).name).to eq("Gb")
    end

    it "should name chromatic degrees bII, bIII, #IV, bVI and bVII by default" do
      expect([1, 3, 6, 8, 10].map { |offset| described_class["C"].shifted(offset).name }).to eq(["Db", "Eb", "F#", "Ab", "Bb"])
      expect([1, 3, 6, 8, 10].map { |offset| described_class["E"].shifted(offset).name }).to eq(["F", "G", "A#", "C", "D"])
    end

    it "should take an explicit letter offset" do
      expect(described_class["C"].shifted(1, 0).name).to eq("C#")
      expect(described_class["C"].shifted(6, 4).name).to eq("Gb")
    end

    it "should respell rather than use a double sharp or flat" do
      expect(described_class["Db"].shifted(1).name).to eq("D")
      expect(described_class["Gb"].shifted(3).name).to eq("A")
      expect(described_class["C#"].shifted(6).name).to eq("G")
    end
  end

  describe "#degree_root" do
    it "should spell roots like #shifted" do
      expect(described_class["E"].degree_root(2).name).to eq("F#")
      expect(described_class["Gb"].degree_root(5).name).to eq("Cb")
      expect(described_class["B"].degree_root(6).name).to eq("E#")
    end

    it "should write lowered degrees that land on Cb or Fb as B or E" do
      expect(described_class["Bb"].degree_root(1).name).to eq("B")
      expect(described_class["Db"].degree_root(3).name).to eq("E")
      expect(described_class["Ab"].degree_root(8).name).to eq("E")
      expect(described_class["Gb"].degree_root(10).name).to eq("E")
    end
  end

  describe ".extract" do
    it "should split off the longest key name" do
      expect(described_class.extract("C#maj7")).to eq([described_class["C#"], "maj7"])
      expect(described_class.extract("Bb Dorian")).to eq([described_class["Bb"], " Dorian"])
    end

    it "should leave strings that don't start with a key alone" do
      expect(described_class.extract("maj7")).to eq([nil, "maj7"])
    end
  end

  describe "#octave_offset" do
    it "should write Cb an octave above, and B# an octave below, the pitch they sound" do
      expect(described_class["Cb"].octave_offset).to eq(1)
      expect(described_class["B#"].octave_offset).to eq(-1)
      expect(described_class["C"].octave_offset).to eq(0)
    end
  end

  describe "#double?" do
    it "should be true only for double sharps and flats" do
      expect(described_class["Bbb"]).to be_double
      expect(described_class["F##"]).to be_double
      expect(described_class["Bb"]).not_to be_double
    end
  end

  describe "hash access" do
    it "should look up by name" do
      expect(described_class["Eb"].long_name).to eq("E Flat")
    end

    it "should look up by index" do
      expect(described_class[3].name).to eq("Eb")
    end
  end
end
