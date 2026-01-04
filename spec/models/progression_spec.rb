require "spec_helper"

RSpec.describe Progression, type: :model do
  it { should belong_to(:progression_family) }
  it { should belong_to(:meter) }
  it { should belong_to(:form) }
  it { should have_many(:components) }
  it { should have_many(:tunes_based_on) }
  it { should have_many(:tune_progressions) }
  it { should have_many(:tunes).through(:tune_progressions) }

  describe "scopes" do
    it "should scope full_tune"
    it "should scope partial"
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
  end

  it "should expose name as #to_s" do
    expect(described_class.new(name: "Test").to_s).to eq("Test")
  end

  it "should expose beats as bars times meter beats" do
    described_class.new(bars: 16).tap do |progression|
      expect(progression).to receive(:meter).and_return(double(:beats, beats: 4))
      expect(progression.beats).to eq(16 * 4)
    end
  end

  it "should delegate resolve to find_by" do
    expect(described_class).to receive(:find_by).with(name: "Test")
    described_class.resolve("Test")
  end

  it "should delegate [] to find_by" do
    expect(described_class).to receive(:find_by).with(name: "Test")
    described_class["Test"]
  end
end
