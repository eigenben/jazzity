require "spec_helper"

RSpec.describe ChordQuality, type: :model do
  context "associations" do
    it { should have_many(:chords) }
  end

  context "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:code) }
  end

  it "should expose #to_s as name" do
    expect(described_class.new(name: "Test").to_s).to eq("Test")
  end

  it "should expose #resolve as an alias for find_by" do
    expect(described_class).to receive(:find_by).with(name: "Major").once
    described_class.resolve("Major")
  end

  it "should expose hash access as an alias for find_by" do
    expect(described_class).to receive(:find_by).with(name: "Major").once
    described_class["Major"]
  end
end
