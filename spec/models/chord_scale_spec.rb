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

  describe "the scales that fit each chord" do
    def scales_for(chord_name)
      chord = Chord.find_by!(name: chord_name)
      chord.chord_scales.map { |chord_scale| chord_scale.mode.clone.in_key_of(Key.default.shifted(chord_scale.offset)).title }
    end

    it "offers Lydian after Ionian over a major 7th" do
      expect(scales_for("Major 7").first(2)).to eq(["C Ionian", "C Lydian"])
    end

    it "offers Lydian dominant and the bebop scale over every plain dominant" do
      ["Dominant 7", "Dominant 9", "Dominant 13"].each do |name|
        expect(scales_for(name)).to include("C Mixolydian", "C Dominant Bebop", "C Lydian Dominant")
      end
    end

    it "offers the blues scale over minor and dominant 7ths" do
      expect(scales_for("Minor 7")).to include("C Minor Blues")
      expect(scales_for("Dominant 7")).to include("C Minor Blues")
    end
  end
end
