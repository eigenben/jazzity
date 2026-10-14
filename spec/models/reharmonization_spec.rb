require "spec_helper"

RSpec.describe Reharmonization do
  def reharmonized(name, key = nil)
    progression = Progression[name].in_key_of(key && Key[key])
    described_class.all(progression.changes, key: progression.key).to_h do |reharmonization|
      [reharmonization.kind, reharmonization.chords.each_with_index.map { |chord, i| reharmonization.changed?(i) ? "[#{chord.lead_sheet_symbol}]" : chord.lead_sheet_symbol }.join(" ")]
    end
  end

  it "replaces dominants with their tritone substitutes" do
    expect(reharmonized("Major ii-V-I")[:tritone_substitutes]).to eq("Dm7 [Db7] Cmaj7")
    expect(reharmonized("Major I-VI-ii-V")[:tritone_substitutes]).to eq("Cmaj7 [Eb7] Dm7 [Db7]")
    expect(reharmonized("Major ii-V-I", "Db")[:tritone_substitutes]).to eq("Ebm7 [D7] Dbmaj7")
  end

  it "substitutes a Lydian dominant for an altered one" do
    expect(reharmonized("Minor ii-V-I")[:tritone_substitutes]).to eq("Dm7b5 [Db7#11] Cm6")
  end

  it "puts the related ii before a dominant that has none" do
    expect(reharmonized("Major I-VI-ii-V")[:related_iis]).to eq("Cmaj7 [Em7b5] A7 Dm7 G7")
    expect(reharmonized("Cycle of Dominants")[:related_iis]).to eq("[Bm7] E7 [Em7] A7 [Am7] D7 [Dm7] G7 Cmaj7")
    expect(reharmonized("Major ii-V-I")).not_to have_key(:related_iis)
  end

  it "brings a V7 into a major chord by the back door" do
    expect(reharmonized("Major ii-V-I")[:backdoor]).to eq("[Fm7] [Bb7] Cmaj7")
    expect(reharmonized("Major ii-V-I", "Eb")[:backdoor]).to eq("[Abm7] [Db7] Ebmaj7")
    expect(reharmonized("Minor ii-V-I")).not_to have_key(:backdoor)
  end

  it "adds passing diminished chords where they fit" do
    expect(reharmonized("Major I-VI-ii-V")[:passing_diminished]).to eq("Cmaj7 [C#dim7] Dm7 G7")
    expect(reharmonized("Minor Blues")[:passing_diminished]).to eq("Cm7 Fm7 Cm7 Ab7 G7alt Cm7 [C#dim7] Dm7b5 G7alt")
    expect(reharmonized("Major ii-V-I")).not_to have_key(:passing_diminished)
  end

  it "leaves the tonic dominants of a blues alone" do
    expect(reharmonized("Basic Blues", "F")[:tritone_substitutes]).to eq("F7 Bb7 F7 Bb7 F7 C7 Bb7 F7 [Gb7]")
  end

  it "offers nothing when there are no dominants or steps to work with" do
    expect(reharmonized("Modal AABA")).to be_empty
  end

  it "turns into a chord sequence in the progression's key" do
    progression = Progression["Major ii-V-I"].in_key_of(Key["Eb"])
    sequence = described_class.all(progression.changes, key: progression.key).first.chord_sequence

    expect(sequence.name).to eq("Fm7, E7, Ebmaj7")
    expect(sequence.key.name).to eq("Eb")
    expect(sequence.analysis.analyzed_chords.map(&:numeral)).to eq(%w[ii7 subV7 Imaj7])
  end

  it "names and describes each kind" do
    reharmonization = described_class.all(Progression["Major ii-V-I"].changes).first
    expect(reharmonization.name).to eq("Tritone substitutes")
    expect(reharmonization.description).to start_with("Each dominant 7th")
    expect(reharmonization.chord_sequence.key).to be_nil
  end
end
