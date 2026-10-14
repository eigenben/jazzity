require "spec_helper"

RSpec.describe ChordNoteSequence do
  subject(:sequence) { described_class.new("D F A C, G B D F") }

  it "splits comma separated groups of notes into note sequences" do
    expect(sequence.note_sequences.map(&:to_s)).to eq(["D F A C", "G B D F"])
  end

  it "identifies every chord each group of notes could spell" do
    expect(sequence.chords.map { |group| group.map(&:title) }).to eq([["F Major 6", "D Minor 7"], ["G Dominant 7"]])
  end

  it "is parameterized without spaces after commas" do
    expect(sequence.to_param).to eq("D F A C,G B D F")
  end

  describe ".resolve" do
    it "returns a sequence of two or more valid note groups" do
      expect(described_class["C E G, F A C"]).to be_a(described_class)
    end

    it "returns nil for a single group" do
      expect(described_class["C E G"]).to be_nil
    end

    it "returns nil if any group contains an invalid note" do
      expect(described_class["C E G, F X C"]).to be_nil
    end
  end
end
