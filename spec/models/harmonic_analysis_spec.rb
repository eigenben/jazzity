require "spec_helper"

RSpec.describe HarmonicAnalysis do
  def analyze(text, hint: nil)
    described_class.new(ChordSequence.new(text).chords, hint: hint && Key[hint])
  end

  def numerals(text)
    analyze(text).analyzed_chords.map(&:numeral)
  end

  describe "#key" do
    {
      "Dm7 G7 Cmaj7" => "C major",
      "Dm7 G7" => "C major",
      "Am7 D7" => "G major",
      "Dm7 G7 Cmaj7 A7" => "C major",
      "Em7b5 A7 Dm7 Db7 Cmaj7" => "C major",
      "Cm7 F7 Bbmaj7 Ebmaj7 Am7b5 D7 Gm6" => "G minor",
      "Dm7b5 G7alt Cm6" => "C minor",
      "Fm7 Bb7 Cmaj7" => "C major",
      "F7 Bb7 F7 Cm7 F7 Bb7 Bdim7 F7 D7 Gm7 C7 F7" => "F major",
      "C#m7 F#7 Bmaj7" => "B major",
      "Gbmaj7 Ebm7 Abm7 Db7" => "Gb major"
    }.each do |changes, key|
      it "hears #{changes} in #{key}" do
        expect(analyze(changes).key.to_s).to eq(key)
      end
    end

    it "spells the tonic as the chords do" do
      expect(analyze("F#m7 B7 Emaj7").key.to_s).to eq("E major")
      expect(analyze("G#m7 C#7 F#maj7").key.to_s).to eq("F# major")
      expect(analyze("Abm7 Db7 Gbmaj7").key.to_s).to eq("Gb major")
      expect(analyze("F#m7 B7 Ebmaj7").key.to_s).to eq("Eb major")
    end

    it "takes a hint from a progression the chords are known to make" do
      expect(analyze("Em7 A7 Dm7 G7", hint: "C").key.to_s).to eq("C major")
      expect(analyze("Em7 A7 Dm7 G7", hint: "F").key.tonic.name).to eq("F")
    end
  end

  describe "#analyzed_chords" do
    it "names diatonic chords by their degree" do
      expect(numerals("Dm7 G7 Cmaj7")).to eq(%w[ii7 V7 Imaj7])
      expect(numerals("Cm7 F7 Bbmaj7 Ebmaj7 Am7b5 D7 Gm6")).to eq(%w[iv7 bVII7 bIIImaj7 bVImaj7 iiø7 V7 i6])
    end

    it "names secondary dominants after the chord they lead to" do
      expect(numerals("Dm7 G7 Cmaj7 A7")).to eq(%w[ii7 V7 Imaj7 V7/ii])
      expect(numerals("Cmaj7 A7 Dm7 G7")).to eq(%w[Imaj7 V7/ii ii7 V7])
      expect(numerals("Cmaj7 E7 Am7 D7 G7 Cmaj7")).to eq(%w[Imaj7 V7/vi vi7 V7/V V7 Imaj7])
    end

    it "names tritone substitutes" do
      expect(numerals("Dm7 Db7 Cmaj7")).to eq(%w[ii7 subV7 Imaj7])
      expect(numerals("Em7b5 A7 Dm7 Db7 Cmaj7")).to eq(%w[iiø7/ii V7/ii ii7 subV7 Imaj7])
      expect(numerals("Cmaj7 Eb7 Dm7 Db7 Cmaj7")).to eq(%w[Imaj7 subV7/ii ii7 subV7 Imaj7])
    end

    it "names chords borrowed from the parallel key" do
      analysis = analyze("Fm7 Bb7 Cmaj7")
      expect(analysis.analyzed_chords.map(&:numeral)).to eq(%w[iv7 bVII7 Imaj7])
      expect(analysis.analyzed_chords.first.role).to eq("Borrowed from C minor")
      expect(numerals("Cmaj7 Fmaj7 Fm6 Cmaj7")).to eq(%w[Imaj7 IVmaj7 iv6 Imaj7])
    end

    it "names passing diminished chords" do
      analysis = analyze("Cmaj7 C#dim7 Dm7 G7")
      expect(analysis.analyzed_chords.map(&:numeral)).to eq(%w[Imaj7 #i°7 ii7 V7])
      expect(analysis.analyzed_chords[1].role).to eq("Passing diminished, rising to ii")
    end

    it "names the dominant 7ths of a blues" do
      expect(numerals("F7 Bb7 F7 Cm7 F7 Bb7 Bdim7 F7 D7 Gm7 C7 F7")).to eq(%w[V7/IV IV7 I7 ii7/IV V7/IV IV7 #iv°7 I7 V7/ii ii7 V7 I7])
    end

    it "marks a chord with no clear part in the key" do
      analysis = analyze("Dm7 Ebm7 Ab7 Dbmaj7")
      expect(analysis.analyzed_chords.first.numeral).to eq("?")
      expect(analysis.analyzed_chords.first).not_to be_clear
      expect(analysis.analyzed_chords.first.role).to eq("Outside the key (bii7)")
    end

    it "suggests the scale among the chord's own that fits the key" do
      scales = analyze("Dm7 G7 Cmaj7").analyzed_chords.map { |chord| chord.scale.title }
      expect(scales).to eq(["D Dorian", "G Mixolydian", "C Ionian"])
      expect(analyze("Am7b5 D7alt Gm6").analyzed_chords.map { |chord| chord.scale.title }).to eq(["A Locrian", "D Super Locrian", "G Melodic Minor"])
      expect(analyze("Am7 D7 Gmaj7").analyzed_chords.first.scale.key.name).to eq("G")
    end

    it "suggests the scales players choose for secondary dominants and substitutes" do
      scales = analyze("Em7b5 A7 Dm7 Db7 Cmaj7").analyzed_chords.map { |chord| chord.scale.title }
      expect(scales).to eq(["E Locrian", "A Mixolydian b6", "D Dorian", "Db Lydian Dominant", "C Ionian"])
    end
  end

  describe "#patterns" do
    def patterns(text)
      analyze(text).patterns.map { |pattern| [pattern.progression.title, pattern.from, pattern.to] }
    end

    it "finds the ii-V-Is and turnarounds inside the chords, in their own keys" do
      expect(patterns("Dm7 G7 Cmaj7 A7")).to eq([["Major ii-V-I Progression", 0, 2]])
      expect(patterns("Em7b5 A7 Dm7 Db7 Cmaj7")).to eq([["Minor ii-V-I Progression in D", 0, 2], ["Tritone Sub ii-V-I Progression", 2, 4]])
      expect(patterns("Cm7 F7 Bbmaj7 Ebmaj7 Am7b5 D7 Gm6")).to eq([["Major ii-V-I Progression in Bb", 0, 2], ["Minor ii-V-I Progression in G", 4, 6]])
      expect(patterns("Cmaj7 C#dim7 Dm7 G7")).to eq([["Diminished Passing Turnaround Progression", 0, 3]])
    end

    it "leaves out a pattern found inside a longer one" do
      expect(patterns("Em7 A7 Dm7 G7").map(&:first)).to eq(["Major iii-VI-ii-V Progression"])
    end

    it "finds nothing in chords that make no known pattern" do
      expect(patterns("Cmaj7 Fmaj7")).to be_empty
    end
  end
end
