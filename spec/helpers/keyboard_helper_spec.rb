require "spec_helper"

RSpec.describe KeyboardHelper, type: :helper do
  def keyboard(...)
    Nokogiri::HTML.fragment(helper.keyboard_tag(...)).at_css("svg")
  end

  def marked(svg, hand)
    svg.css(".keyboard-key.is-#{hand}").map { |key| key["data-midi"].to_i }
  end

  def pitches(*names)
    names.map { |name| Pitch.parse(name) }
  end

  describe "#keyboard_tag" do
    it "draws whole octaves of keys, white and black, around the notes" do
      svg = keyboard(pitches("C/4", "E/4", "G/4", "B/4"))

      expect(svg.css(".keyboard-white").size).to eq(14)
      expect(svg.css(".keyboard-black").size).to eq(10)
      expect(svg.css(".keyboard-key").map { |key| key["data-midi"].to_i }.sort).to eq((60..83).to_a)
    end

    it "marks the notes in the right hand's colour and the left hand's apart" do
      voiced = VoiceLeader.new([Chord["Dm7"]]).voiced_chords.first
      svg = keyboard(voiced.treble, left: voiced.bass)

      expect(marked(svg, :left)).to eq([38])
      expect(marked(svg, :right)).to eq([60, 64, 65, 69])
      expect(svg["aria-label"]).to eq("Piano keyboard: left hand D2, right hand C4 E4 F4 A4")
    end

    it "writes the names of the marked notes on their keys, and the octave on each C" do
      svg = keyboard(pitches("Eb/4", "G/4", "Bb/4"))

      expect(svg.at_css("[data-midi='63'] text").text).to eq("E♭")
      expect(svg.at_css("[data-midi='70'] text").text).to eq("B♭")
      expect(svg.at_css("[data-midi='72'] text").text).to eq("C5")
      expect(svg.at_css("[data-midi='62'] text").text).to be_empty
    end

    it "spells the notes as they're written" do
      svg = keyboard(pitches("F#/4", "A#/4", "C#/5"))

      expect(svg.at_css("[data-midi='66'] text").text).to eq("F♯")
      expect(svg["aria-label"]).to eq("Piano keyboard: F#4 A#4 C#5")
    end

    it "takes MIDI notes and a range to draw" do
      svg = keyboard([60, 64], range: 48..71)

      expect(svg.css(".keyboard-key").size).to eq(24)
      expect(marked(svg, :right)).to eq([60, 64])
      expect(svg["data-controller"]).to eq("keyboard")
    end
  end

  describe "#keyboard_range" do
    it "starts on the C or F at or below the lowest note and ends on the E or B at or above the highest" do
      expect(helper.keyboard_range(pitches("D/2", "A/4"))).to eq(36..71)
      expect(helper.keyboard_range(pitches("Ab/3", "F/5"))).to eq(53..83)
    end

    it "spans at least two octaves" do
      expect(helper.keyboard_range(pitches("D/4", "C/5"))).to eq(60..88)
      expect(helper.keyboard_range([])).to eq(60..83)
    end
  end
end
