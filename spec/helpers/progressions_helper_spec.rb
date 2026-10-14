require "spec_helper"

RSpec.describe ProgressionsHelper, type: :helper do
  describe "#chord_symbol" do
    it "writes sharps and flats with their signs" do
      expect(helper.chord_symbol(Chord["Bbm7b5"])).to eq(%(B<span class="accidental">♭</span>m7<span class="accidental">♭</span>5))
      expect(strip_tags(helper.chord_symbol(Chord["F#7#11"]))).to eq("F♯7♯11")
      expect(helper.chord_symbol(Chord["Cmaj7"])).to eq("Cmaj7")
    end
  end

  describe "#roman_numeral" do
    def numeral(text)
      helper.roman_numeral(RomanNumerals::Numeral.parse(text))
    end

    it "writes accidentals with their signs" do
      expect(numeral("bVII7")).to eq("♭VII7")
      expect(numeral("#iv°7")).to eq("♯iv°7")
      expect(numeral("V7b9")).to eq("V7♭9")
    end

    it "drops the m or maj a chart uses to ask for a triad" do
      expect(numeral("im")).to eq("i")
      expect(numeral("Imaj")).to eq("I")
      expect(numeral("imaj7")).to eq("imaj7")
      expect(numeral("Imaj7")).to eq("Imaj7")
    end
  end
end
