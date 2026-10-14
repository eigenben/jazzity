require "spec_helper"

RSpec.describe ScaleName do
  def target_of(text)
    described_class.resolve(text)
  end

  it "reads a mode with its key before or after the name" do
    ["D dorian", "dorian D", "Dorian in D", "D Dorian scale", "d DORIAN"].each do |text|
      mode = target_of(text)
      expect([mode.class, mode.title, mode.notes.first]).to eq([Mode, "D Dorian", "D"]), text
    end
  end

  it "places a mode's parent scale in the key that starts the mode on its note" do
    mode = target_of("Ab Lydian Augmented")
    expect(mode.title).to eq("Ab Lydian Augmented")
    expect(mode.key.name).to eq("F")
    expect(mode.notes).to eq(%w[Ab Bb C D E F G])
  end

  it "reads scales in sharp and flat keys typed in lowercase" do
    expect(target_of("f# melodic minor").title).to eq("The F# Melodic Minor Scale")
    expect(target_of("Bb major scale").title).to eq("The Bb Major Scale")
  end

  it "takes a spelled-out major or minor to mean the scale" do
    expect(target_of("C major").title).to eq("The C Major Scale")
    expect(target_of("C minor").title).to eq("C Aeolian")
  end

  it "knows a few other common names" do
    expect(target_of("G altered scale").title).to eq("G Super Locrian")
    expect(target_of("C jazz minor").title).to eq("The C Melodic Minor Scale")
    expect(target_of("half-whole").title).to eq("The Diminished Scale")
  end

  it "reads a name without a key" do
    expect(target_of("lydian").name).to eq("Lydian")
    expect(target_of("whole tone").name).to eq("Whole Tone")
    expect(target_of("lydian").key).to be_nil
  end

  it "returns nil for anything that isn't a scale" do
    ["bebop", "C E G", "Cmaj7", "xyzzy", "D dorain"].each do |text|
      expect(described_class.parse(text)).to be_nil, text
    end
  end

  describe "Mode.resolve" do
    it "starts the mode on the note it is given" do
      expect(Mode["D Dorian"].notes).to eq(%w[D E F G A B C])
    end
  end
end
