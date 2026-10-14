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

  describe "#shifted" do
    it "should move up by semitones, wrapping around the octave" do
      expect(described_class["C"].shifted(2).name).to eq("D")
      expect(described_class["Bb"].shifted(3).name).to eq("Db")
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
