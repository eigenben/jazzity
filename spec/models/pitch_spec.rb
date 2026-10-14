require "spec_helper"

RSpec.describe Pitch do
  it "writes the note name and octave of a MIDI note" do
    expect(described_class.new(Key["Eb"], 63).to_s).to eq("Eb/4")
    expect(described_class.new(Key["C"], 60).to_s).to eq("C/4")
  end

  it "writes Cb and B# in the octave of their letter" do
    expect(described_class.new(Key["Cb"], 59).to_s).to eq("Cb/4")
    expect(described_class.new(Key["B#"], 60).to_s).to eq("B#/3")
  end

  it "finds the lowest pitch of a key at or above a MIDI note" do
    expect(described_class.at_or_above(Key["D"], 60).midi).to eq(62)
    expect(described_class.at_or_above(Key["C"], 60).midi).to eq(60)
  end

  it "finds the nearest pitch of a key, preferring the lower" do
    expect(described_class.nearest(Key["B"], 60).midi).to eq(59)
    expect(described_class.nearest(Key["F#"], 60).midi).to eq(54)
  end

  it "moves by octaves" do
    expect(described_class.new(Key["G"], 55).octaves(1).to_s).to eq("G/4")
  end

  it "compares by sound" do
    expect(described_class.new(Key["Cb"], 59)).to be < described_class.new(Key["C"], 60)
  end
end
