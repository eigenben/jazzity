require "spec_helper"

RSpec.describe Tune, type: :model do
  context "associations" do
    it { should belong_to(:meter) }
    it { should belong_to(:form) }
    it { should belong_to(:starting_chord) }
    it { should belong_to(:ending_chord) }
    it { should belong_to(:contrafact_of_tune) }
    it { should belong_to(:based_on_progression) }
    it { should have_many(:tune_progressions) }
    it { should have_many(:progressions).through(:tune_progressions) }
  end

  context "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_inclusion_of(:tonality).in_array(%w[Major Minor]) }
  end

  it "should expose title as #to_s" do
    described_class.new.tap do |tune|
      expect(tune).to receive(:title).and_return("Test")
      expect(tune.to_s).to eq("Test")
    end
  end

  describe "title" do
    it "should be name when no alternate name" do
      expect(described_class.new(name: "Tune").title).to eq("Tune")
    end

    it "should be name with alternate name in parenthesis when no alternate name" do
      expect(described_class.new(name: "Tune", alternate_name: "Alt").title).to eq("Tune (Alt)")
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
