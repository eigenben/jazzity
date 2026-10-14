require "spec_helper"

RSpec.describe ChordSymbol, type: :model do
  context "associations" do
    it { should belong_to(:chord) }
  end

  context "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:chord) }
  end

  describe "resolution" do
    it "should distinguish case-sensitive symbols such as M7 and m7" do
      expect(described_class["M7"].chord.name).to eq("Major 7")
      expect(described_class["m7"].chord.name).to eq("Minor 7")
    end

    it "should match other symbols regardless of case" do
      expect(described_class["MAJ7"].chord.name).to eq("Major 7")
    end

    it "should return nil for unknown symbols" do
      expect(described_class["xyz"]).to be_nil
    end
  end
end
