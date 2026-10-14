require "spec_helper"

RSpec.describe NoteSequence do
  subject(:sequence) { described_class.new("C E G") }

  it "parses space separated note names" do
    expect(sequence.notes).to eq(["C", "E", "G"])
  end

  it "keeps track of notes it does not recognize" do
    expect(described_class.new("C X G").invalid_keys).to eq(["X"])
  end

  it "places notes in ascending octaves for the staff" do
    expect(sequence.octavized_notes).to eq(["C/4", "E/4", "G/4"])
    expect(sequence.staff_notes).to eq([["C/4"], ["E/4"], ["G/4"]])
  end

  it "identifies the chords the notes spell" do
    expect(sequence.chords.map(&:title)).to eq(["C Major Triad"])
  end

  it "identifies chords regardless of the order of the notes" do
    expect(described_class.new("G C E").chords.map(&:title)).to eq(["C Major Triad"])
  end

  describe ".resolve" do
    it "returns a sequence of valid notes" do
      expect(described_class["C E G"]).to be_a(described_class)
    end

    it "returns nil if any note is invalid" do
      expect(described_class["C X G"]).to be_nil
    end
  end
end
