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

  it "names chords from the notes as written" do
    expect(described_class.new("F# A# C#").chords.map(&:title)).to eq(["F# Major Triad"])
    expect(described_class.new("Gb Bb Db").chords.map(&:title)).to eq(["Gb Major Triad"])
    expect(described_class.new("D F A C").chords.map(&:title)).to eq(["D Minor 7", "F Major 6"])
  end

  it "reads notes typed in lowercase or with double flats" do
    expect(described_class.new("c eb gb bbb").notes).to eq(%w[C Eb Gb Bbb])
  end

  it "moves the notes so the first is in the key asked for" do
    expect(described_class.new("C E G").in_key_of("Eb").notes).to eq(%w[Eb G Bb])
    expect(described_class.new("D F A C").in_key_of("E").notes).to eq(%w[E G B D])
  end

  it "finds the scales that fit, in the chord's key" do
    expect(described_class.new("D F A C").modes.map(&:title)).to include("D Dorian")
  end

  describe ".resolve" do
    it "returns a sequence of valid notes" do
      expect(described_class["C E G"]).to be_a(described_class)
    end

    it "returns nil if any note is invalid" do
      expect(described_class["C X G"]).to be_nil
    end

    it "returns nil for more than MAX_NOTES notes" do
      expect(described_class[(["C"] * NoteSequence::MAX_NOTES).join(" ")]).to be_a(described_class)
      expect(described_class[(["C"] * (NoteSequence::MAX_NOTES + 1)).join(" ")]).to be_nil
    end
  end
end
