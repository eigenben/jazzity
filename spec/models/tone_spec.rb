require "spec_helper"

RSpec.describe Tone do
  it "assigns attributes from a hash with string or symbol keys" do
    tone = described_class.new("tone" => 4, :letter_index => 2, :position => 3)
    expect([tone.tone, tone.letter_index, tone.position]).to eq([4, 2, 3])
  end

  it "serializes to the hash it was built from" do
    tone = described_class.new(:tone => 7, :letter_index => 4, :position => 5)
    expect(tone.as_json).to eq(:tone => 7, :letter_index => 4, :position => 5)
  end
end
