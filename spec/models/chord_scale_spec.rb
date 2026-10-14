require "spec_helper"

RSpec.describe ChordScale, type: :model do
  context "associations" do
    it { should belong_to(:chord) }
    it { should belong_to(:mode) }
  end

  context "delegations" do
    it "should delegate scale to mode" do
      scale = Scale.new(name: "Major")
      expect(described_class.new(mode: Mode.new(scale: scale)).scale).to eq(scale)
    end

    it "should delegate key to chord" do
      chord_scale = described_class.new(chord: Chord.new.in_key_of("Eb"))
      expect(chord_scale.key.name).to eq("Eb")
    end
  end
end
