require 'spec_helper'

RSpec.describe Voicing, type: :model do
  describe 'associations' do
    it { should belong_to(:voicing_family) }
    it { should belong_to(:chord) }
    it { should belong_to(:upper_structure_chord) }
  end

  describe "drop 2 voicings" do
    it "drops the second note from the top of each close inversion an octave" do
      voicings = Chord.find_by!(name: "Major 7").voicings.joins(:voicing_family).where(voicing_families: {name: "Drop 2"})

      expect(voicings.map { |voicing| [voicing.name, voicing.tones.notes.join(" ")] }).to eq([
        ["Drop 2 I", "G C E B"], ["Drop 2 II", "B E G C"], ["Drop 2 III", "C G B E"], ["Drop 2 IV", "E B C G"]
      ])
    end
  end

  describe "So What voicings" do
    it "stacks three 4ths and a major 3rd on a minor 7th" do
      voicing = Chord.find_by!(name: "Minor 7").voicings.find_by!(name: "So What I")

      expect(voicing.tones.in_key_of(Key["D"]).notes).to eq(%w[D G C F A])
    end
  end
end
