require "spec_helper"

RSpec.describe KeyedQuery do
  def readings(text)
    described_class.parse(text).map { |reading| [reading.key&.name, reading.text] }
  end

  it "always offers the whole text without a key first" do
    expect(readings("lydian")).to eq([[nil, "lydian"]])
  end

  it "finds a key before the rest" do
    expect(readings("Eb ii-V-I")).to include(["Eb", "ii-V-I"])
    expect(readings("f# melodic minor")).to include(["F#", "melodic minor"])
  end

  it "finds a key after the rest, with or without 'in'" do
    expect(readings("dorian D")).to include(["D", "dorian"])
    expect(readings("ii V I in Eb")).to include(["Eb", "ii V I"])
    expect(readings("Jazz Blues in the key of F")).to include(["F", "Jazz Blues"])
  end

  it "ignores words that are not keys" do
    expect(readings("Mixolydian b6")).to eq([[nil, "Mixolydian b6"]])
  end
end
