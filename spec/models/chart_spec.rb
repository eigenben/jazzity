require "spec_helper"

RSpec.describe Chart do
  def symbols(text, key = nil)
    chart = described_class.parse!(text)
    chart.in_key_of(Key[key]) if key
    chart.bars.map { |bar| bar.chords.map(&:lead_sheet_symbol) }
  end

  it "reads bars of roman numerals between barlines" do
    expect(symbols("| ii7 | V7 | Imaj7 |")).to eq([%w[Dm7], %w[G7], %w[Cmaj7]])
  end

  it "shares a bar between the chords written in it" do
    chart = described_class.parse!("| Imaj7 vi7 | ii7 V7 |")
    expect(chart.bars.map(&:size)).to eq([2, 2])
    expect(chart.positions_per_bar).to eq(2)
  end

  it "repeats the bar before for %" do
    chart = described_class.parse!("| I7 | % | IV7 | % |")
    expect(chart.bars.map(&:to_s)).to eq(%w[I7 % IV7 %])
    expect(chart.bars.map { |bar| bar.chords.map(&:lead_sheet_symbol) }).to eq([%w[C7], %w[C7], %w[F7], %w[F7]])
    expect(chart.bars.map(&:repeat?)).to eq([false, true, false, true])
  end

  it "numbers the bars through the whole chart" do
    expect(described_class.parse!("A: | I | V |\nB: | IV | I |").bars.map(&:number)).to eq([1, 2, 3, 4])
  end

  it "reads labelled sections and the form they make" do
    chart = described_class.parse!("A: | I6 vi7 | ii7 V7 |\nA: | I6 vi7 | ii7 V7 |\nB: | III7 | % |\nA: | I6 | % |")
    expect(chart.sections.map(&:label)).to eq(%w[A A B A])
    expect(chart.sections.map { |section| section.bars.size }).to eq([2, 2, 2, 2])
    expect(chart.form).to eq("A-A-B-A")
    expect(described_class.parse!("| I | V |").form).to be_nil
  end

  it "realizes the chords in any key, spelled from the key" do
    expect(symbols("| ii7 V7 | Imaj7 |", "E")).to eq([%w[F#m7 B7], %w[Emaj7]])
    expect(symbols("| #iv°7 | bVII7 | V7/ii |", "Bb")).to eq([%w[Edim7], %w[Ab7], %w[G7]])
  end

  it "lists its components with positions, degrees and chords" do
    components = described_class.parse!("| ii7 V7 | Imaj7 | #iv°7 |").components
    expect(components.map { |c| [c[:position], c[:index], c[:degree], c[:chord].name] }).to eq([
      [1, 2, 2, "Minor 7"], [2, 7, 5, "Dominant 7"], [3, 0, 1, "Major 7"], [5, 6, 4, "Diminished 7"]
    ])
  end

  it "accepts barlines with or without spaces, and doubled at the ends" do
    expect(symbols("||ii7|V7 | Imaj7||")).to eq([%w[Dm7], %w[G7], %w[Cmaj7]])
  end

  it "writes itself back out" do
    text = "A: | Imaj7 vi7 | ii7 V7 | % |\nB: | III7 |"
    expect(described_class.parse!(text).to_s).to eq(text)
  end

  it "says what it can't read" do
    expect { described_class.parse!("| ii7 | xyz |") }.to raise_error(Chart::ParseError, /Bar 2 has “xyz”/)
    expect { described_class.parse!("| % | I |") }.to raise_error(Chart::ParseError, /none before it/)
    expect { described_class.parse!("A: B: | I |") }.to raise_error(Chart::ParseError, /Section A has no bars/)
    expect(described_class.parse("")).to be_nil
    expect(described_class.parse("| Cmaj7 |")).to be_nil
  end
end
