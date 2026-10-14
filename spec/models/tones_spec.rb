require "spec_helper"

RSpec.describe Tones do
  def tones_for(*intervals)
    described_class.new(intervals.each_with_index.map do |interval, i|
      Tone.new(:tone => Key::Intervals[interval], :letter_index => Key::IntervalLetterIndexes[interval], :position => i + 1)
    end)
  end

  let(:major_triad) { tones_for("u", "3", "5") }
  let(:major_scale) { tones_for("u", "2", "3", "4", "5", "6", "7") }

  it "realizes notes relative to C when no key is given" do
    expect(major_triad.notes).to eq(["C", "E", "G"])
  end

  describe "#in_key_of" do
    it "transposes into the key" do
      expect(major_triad.in_key_of("Eb").notes).to eq(["Eb", "G", "Bb"])
    end

    it "spells notes by letter rather than defaulting to flats" do
      expect(major_triad.in_key_of("F#").notes).to eq(["F#", "A#", "C#"])
    end

    it "leaves the original tones untouched" do
      major_triad.in_key_of("Eb")
      expect(major_triad.notes).to eq(["C", "E", "G"])
    end
  end

  describe "#in_mode" do
    it "rotates the tones to start on the given degree" do
      expect(major_scale.in_mode(2).notes).to eq(["D", "E", "F", "G", "A", "B", "C"])
    end

    it "combines with a key" do
      expect(major_scale.in_key_of("Bb").in_mode(5).notes).to eq(["F", "G", "A", "Bb", "C", "D", "Eb"])
    end
  end

  describe "#octavized_notes" do
    it "places notes in ascending octaves" do
      expect(major_triad.in_key_of("G").octavized_notes).to eq(["G/4", "B/4", "D/5"])
    end

    it "starts roots from Ab upward an octave lower to stay on the staff" do
      expect(major_triad.in_key_of("A").octavized_notes).to eq(["A/3", "C#/4", "E/4"])
    end
  end

  describe "#pitches" do
    it "stacks the tones upward from a MIDI note" do
      expect(major_triad.in_key_of("A").pitches(57).map(&:to_s)).to eq(["A/3", "C#/4", "E/4"])
    end

    it "starts on the first tone at or above the MIDI note" do
      expect(major_triad.in_key_of("A").pitches(58).map(&:to_s)).to eq(["A/4", "C#/5", "E/5"])
    end

    it "puts a repeated tone an octave higher" do
      expect(tones_for("u", "3", "5", "u").pitches(48).map(&:midi)).to eq([48, 52, 55, 60])
    end
  end

  it "exposes intervals between successive tones" do
    expect(major_triad.intervals).to eq([4, 3])
    expect(major_triad.interval_names).to eq(["M3", "m3"])
  end
end
