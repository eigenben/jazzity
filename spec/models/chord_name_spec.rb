require "spec_helper"

RSpec.describe ChordName do
  def title_of(text)
    described_class.parse(text)&.chord&.title
  end

  {
    "Cmaj7" => "C Major 7", "C#maj7" => "C# Major 7", "Dbmaj7" => "Db Major 7", "C maj7" => "C Major 7",
    "Cm7b5" => "C Half Diminished", "Cø7" => "C Half Diminished", "Cø" => "C Half Diminished", "C-7b5" => "C Half Diminished",
    "C-7" => "C Minor 7", "Cmin7" => "C Minor 7", "Cmi7" => "C Minor 7", "Cm9" => "C Minor 9",
    "Cdim7" => "C Diminished 7", "Co7" => "C Diminished 7", "C°7" => "C Diminished 7", "Cdim" => "C Diminished Triad",
    "C7b5" => "C Dominant b5", "C13" => "C Dominant 13", "C9" => "C Dominant 9",
    "Bbm7" => "Bb Minor 7", "BbM7" => "Bb Major 7", "Cmaj9" => "C Major 9",
    "CΔ7" => "C Major 7", "CΔ" => "C Major 7", "C^7" => "C Major 7", "CMa7" => "C Major 7",
    "C7sus4" => "C Dominant 7 sus4", "Csus" => "C Suspended 4",
    "C7(b9)" => "C Dominant b9", "C7(#9)" => "C Dominant #9", "C7-9" => "C Dominant b9", "C7+5" => "C Augmented 7",
    "C+" => "C Augmented Triad", "Calt" => "C Altered", "Galt" => "G Altered", "C alt" => "C Altered", "C7alt" => "C Altered",
    "C-Δ7" => "C Minor-Major 7", "Cm(maj7)" => "C Minor-Major 7",
    "C" => "C Major Triad", "Eb" => "Eb Major Triad", "F#" => "F# Major Triad", "ebmaj7" => "Eb Major 7", "f#m7" => "F# Minor 7",
    "C Major 7" => "C Major 7", "G half diminished chord" => "G Half Diminished", "E♭m7" => "Eb Minor 7"
  }.each do |text, title|
    it "reads #{text} as #{title}" do
      expect(title_of(text)).to eq(title)
    end
  end

  it "keeps case-sensitive symbols apart" do
    expect(title_of("Cm7")).to eq("C Minor 7")
    expect(title_of("CM7")).to eq("C Major 7")
    expect(title_of("Cm")).to eq("C Minor Triad")
    expect(title_of("CM")).to eq("C Major Triad")
  end

  it "resolves a slash chord to its chord and records the bass" do
    name = described_class.parse("C7/E")
    expect(name.chord.title).to eq("C Dominant 7")
    expect(name.bass.name).to eq("E")
    expect(name.to_s).to eq("C7/E")
  end

  it "does not mistake a 6/9 for a slash chord" do
    expect(title_of("C6/9")).to eq("C Major 6/9")
  end

  it "reads a quality without a root as a chord with no key" do
    name = described_class.parse("maj7")
    expect(name).not_to be_rooted
    expect(name.chord.key).to be_nil
  end

  it "writes the chord name with the symbol it matched" do
    expect(described_class.parse("C^7").to_s).to eq("Cmaj7")
    expect(described_class.parse("Eb").to_s).to eq("Eb")
    expect(described_class.parse("C7(b9)").to_s).to eq("C7b9")
  end

  it "returns nil for anything that isn't a chord" do
    %w[xyzzy blues dorian bebop Cfoo H7].push("", "C E G").each do |text|
      expect(described_class.parse(text)).to be_nil, text
    end
  end

  it "gives each parse its own chord to place in a key" do
    first = described_class.parse("Cmaj7").chord
    second = described_class.parse("Ebmaj7").chord
    expect([first.key.name, second.key.name]).to eq(["C", "Eb"])
  end
end
