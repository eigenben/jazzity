require "spec_helper"

RSpec.describe VoiceLeader do
  def chords(symbols)
    ChordSequence.new(symbols).chords
  end

  def family(name)
    VoicingFamily.find_by!(name: name)
  end

  def voice(symbols, **options)
    described_class.new(chords(symbols), **options).voiced_chords
  end

  let(:two_five_one) { voice("Dm7 G7 Cmaj7") }

  it "voices every chord" do
    expect(two_five_one.map { |voiced| voiced.chord.lead_sheet_symbol }).to eq(%w[Dm7 G7 Cmaj7])
  end

  it "gives the same voicings every time" do
    5.times { expect(voice("Dm7 G7 Cmaj7").map(&:notes)).to eq(two_five_one.map(&:notes)) }
  end

  it "defaults to rootless Type I/II voicings" do
    expect(two_five_one.map { |voiced| voiced.voicing.voicing_family.name }.uniq).to eq(["4-Note Rootless (Type I/II)"])
  end

  it "alternates Type I and II through a ii-V-I so the voices move by step" do
    expect(two_five_one.map(&:name)).to eq(["Type II", "Type I", "Type II"])
    expect(two_five_one.map(&:notes)).to eq([%w[C/4 E/4 F/4 A/4], %w[B/3 D/4 F/4 A/4], %w[B/3 D/4 E/4 G/4]])
  end

  it "holds common tones" do
    dm7, g7, cmaj7 = two_five_one.map { |voiced| voiced.pitches.map(&:midi) }

    expect(dm7 & g7).to eq([65, 69]) # F and A
    expect(g7 & cmaj7).to eq([59, 62]) # B and D
  end

  it "spells notes in the chord's key" do
    expect(voice("F#m7 B7 Emaj7").map(&:notes)).to eq([%w[E/4 G#/4 A/4 C#/5], %w[D#/4 F#/4 A/4 C#/5], %w[D#/4 F#/4 G#/4 B/4]])
  end

  it "keeps rootless voicings in the right-hand register over a low root" do
    blues = Progression.find_by!(slug: "jazz-blues").in_key_of(Key["F"])
    rhythm = Progression.find_by!(slug: "original-rhythm-changes").in_key_of(Key["Bb"])

    (blues.voiced_chords + rhythm.voiced_chords).each do |voiced|
      expect(voiced.pitches.first.midi).to be >= described_class::RIGHT_HAND.low
      expect(voiced.pitches.last.midi).to be <= described_class::RIGHT_HAND.high
      expect(described_class::BASS.low..described_class::BASS.high).to include(voiced.root.midi)
    end
  end

  it "moves the bass to the nearest octave of each root" do
    roots = voice("Dm7 G7 Cmaj7").map { |voiced| voiced.root.to_s }
    expect(roots).to eq(%w[D/2 G/2 C/3])
  end

  it "plays rooted voicings in the left hand alone, above the lower interval limits" do
    voiced = voice("Dm7 G7 Cmaj7 Fmaj7 Bm7b5 E7 Am7", family: family("Rooted Guide Tones"))

    voiced.each do |chord|
      expect(chord).not_to be_over_root
      expect(chord.treble).to be_empty
      chord.pitches.each_cons(2) do |lower, upper|
        expect(lower.midi).to be >= described_class::LOWER_INTERVAL_LIMITS.fetch(upper.midi - lower.midi, 0)
      end
    end
  end

  it "voices a whole progression in the family asked for" do
    voiced = Progression.find_by!(slug: "jazz-blues").voiced_chords(family: family("Guide Tones"))
    expect(voiced.map { |chord| chord.voicing.voicing_family.name }.uniq).to eq(["Guide Tones"])
  end

  it "falls back to the nearest family for chords the family lacks" do
    voiced = voice("Cmaj Fmaj7")

    expect(voiced.first.voicing.voicing_family.name).to eq("Triads")
    expect(voiced.last.voicing.voicing_family.name).to eq("4-Note Rootless (Type I/II)")
    expect(voiced.first).to be_over_root
  end

  it "falls back to the chord's own tones for a chord with no voicings" do
    voiced = voice("Cphryg Dm7").first
    expect(voiced.voicing).to be_nil
    expect(voiced.notes.size).to eq(voiced.chord.notes.size)
  end

  it "uses a voicing picked for a chord and voice-leads the rest from it" do
    type_i = chords("Dm7").first.voicings.find_by!(name: "Type I")
    voiced = voice("Dm7 G7 Cmaj7", overrides: {"0" => type_i.id.to_s})

    expect(voiced.map(&:name)).to eq(["Type I", "Type II", "Type I"])
  end

  it "ignores picks that aren't voicings of the chord" do
    other = chords("G7").first.voicings.first
    voiced = voice("Dm7 G7 Cmaj7", overrides: {"0" => other.id.to_s, "1" => "nonsense"})

    expect(voiced.map(&:notes)).to eq(two_five_one.map(&:notes))
  end

  it "splits a two-handed upper structure between the hands" do
    upper = chords("C7alt").first.voicings.find_by!(name: "Dominant #5 Upper Structure I")
    voiced = voice("C7alt", overrides: {0 => upper}).first

    expect(voiced.bass.map(&:to_s)).to eq(%w[C/3 E/3 Bb/3])
    expect(voiced.treble.map(&:to_s)).to eq(%w[Ab/4 C/5 Eb/5])
  end

  it "describes each chord for the staff" do
    expect(two_five_one.first.to_staff).to eq(:symbol => "Dm7", :bass => %w[D/2], :treble => %w[C/4 E/4 F/4 A/4])
  end
end
