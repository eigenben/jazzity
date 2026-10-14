require "spec_helper"

RSpec.describe Chords do
  let(:chords) { Mode.find_by!(name: "Dorian").chords }

  it "lists chord symbols" do
    expect(chords.symbols).to eq(["min", "min7", "min6"])
    expect(chords.to_s).to eq("min, min7, min6")
  end

  it "lists chord names" do
    expect(chords.names).to eq(["Minor Triad", "Minor 7", "Minor 6"])
    expect(chords.to_s(:names)).to eq("Minor Triad, Minor 7, Minor 6")
  end
end
