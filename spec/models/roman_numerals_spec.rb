require "spec_helper"

RSpec.describe RomanNumerals do
  def symbols(text, key = nil)
    numerals = described_class.parse(text)
    numerals = numerals.in_key_of(key) if key
    numerals.chords.map(&:lead_sheet_symbol)
  end

  def progressions(text)
    described_class.parse(text).progressions.map(&:title)
  end

  it "parses each numeral into a degree, an accidental and a chord" do
    numerals = described_class.parse("ii7 V7 Imaj7")
    expect(numerals.map { |numeral| [numeral.degree, numeral.accidental, numeral.chord.name] }).to eq([[2, 0, "Minor 7"], [5, 0, "Dominant 7"], [1, 0, "Major 7"]])
  end

  it "reads the quality after a lowercase numeral as minor" do
    expect(symbols("ii7 ii9 i6 iiø vii°7")).to eq(%w[Dm7 Dm9 Cm6 Dm7b5 Bdim7])
  end

  it "assumes the seventh chords a jazz player would when no quality is written" do
    expect(symbols("I ii iii IV V vi vii")).to eq(%w[Cmaj7 Dm7 Em7 Fmaj7 G7 Am7 Bm7b5])
    expect(symbols("bII bIII bVI bVII II")).to eq(%w[Db7 Ebmaj7 Abmaj7 Bb7 D7])
  end

  it "accepts spaces, dashes, commas and barlines between numerals" do
    ["ii V I", "ii-V-I", "ii, V, I", "ii | V | I", "ii–V–I"].each do |text|
      expect(symbols(text)).to eq(%w[Dm7 G7 Cmaj7]), text
    end
  end

  it "reads the scale degree shorthand" do
    expect(symbols("251")).to eq(%w[Dm7 G7 Cmaj7])
    expect(symbols("1625")).to eq(%w[Cmaj7 Am7 Dm7 G7])
    expect(symbols("3-6-2-5")).to eq(%w[Em7 Am7 Dm7 G7])
  end

  it "builds secondary chords on the degree they lead to" do
    expect(symbols("V7/ii ii7 V7/V V7")).to eq(%w[A7 Dm7 D7 G7])
  end

  it "realizes the chords in any key, spelled from the key" do
    expect(symbols("ii V I", "E")).to eq(%w[F#m7 B7 Emaj7])
    expect(symbols("bII7 I", "Bb")).to eq(%w[B7 Bbmaj7])
  end

  it "reads a key named before or after the numerals" do
    expect(described_class.parse("ii V I in Eb").key.name).to eq("Eb")
    expect(described_class.parse("Eb ii-V-I").key.name).to eq("Eb")
  end

  it "finds known progressions by degree and kind of chord" do
    expect(progressions("ii V I")).to eq(["Major ii-V-I Progression"])
    expect(progressions("ii7 V7 Imaj7")).to eq(["Major ii-V-I Progression"])
    expect(progressions("iiø V i")).to eq(["Minor ii-V-I Progression"])
    expect(progressions("iii VI7 ii V")).to eq(["Major iii-VI-ii-V Progression"])
    expect(described_class.parse("ii V I in Eb").progressions.map(&:title)).to eq(["Major ii-V-I Progression in Eb"])
  end

  it "picks the progression whose chords are exactly the ones assumed" do
    numerals = described_class.parse("ii V")
    expect(numerals.progressions.map(&:name)).to eq(["Major ii-V", "Minor ii-V"])
    expect(numerals.progression.name).to eq("Major ii-V")
  end

  it "finds no progression when the chords differ in kind" do
    expect(progressions("I vi ii V")).to be_empty
  end

  it "turns into a chord sequence" do
    expect(described_class.parse("I vi ii V").in_key_of("F").chord_sequence.name).to eq("Fmaj7, Dm7, Gm7, C7")
  end

  it "returns nil unless every part is a numeral" do
    ["blues", "C E G", "Cmaj7", "ii V xyz", "13", ""].each do |text|
      expect(described_class.parse(text)).to be_nil, text
    end
  end
end
