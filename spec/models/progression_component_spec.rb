require "spec_helper"

RSpec.describe ProgressionComponent, type: :model do
  describe "associations" do
    it { should belong_to(:progression) }
    it { should belong_to(:chord) }
  end

  describe "validations" do
    it { should validate_inclusion_of(:index).in_range(0..11) }
  end

  describe "#degree" do
    it "defaults from the index, reading chromatic steps as bII, bIII, #IV, bVI and bVII" do
      degrees = (0..11).map { |index| described_class.new(:index => index).tap(&:valid?).degree }
      expect(degrees).to eq([1, 2, 2, 3, 3, 4, 4, 5, 6, 6, 7, 7])
    end

    it "keeps a degree that was given" do
      expect(described_class.new(:index => 1, :degree => 1).tap(&:valid?).degree).to eq(1)
    end
  end

  describe "#root_in" do
    it "spells the root from its degree in the key" do
      expect(described_class.new(:index => 2, :degree => 2).root_in(Key["E"]).name).to eq("F#")
      expect(described_class.new(:index => 1, :degree => 2).root_in(Key["C"]).name).to eq("Db")
      expect(described_class.new(:index => 1, :degree => 1).root_in(Key["C"]).name).to eq("C#")
      expect(described_class.new(:index => 6, :degree => 4).root_in(Key["Bb"]).name).to eq("E")
    end

    it "uses C when there is no key" do
      expect(described_class.new(:index => 7, :degree => 5).root_in(nil).name).to eq("G")
    end
  end

  describe "#key_from_root" do
    it "finds the key a root belongs to" do
      expect(described_class.new(:index => 2, :degree => 2).key_from_root(Key["F#"]).name).to eq("E")
      expect(described_class.new(:index => 2, :degree => 2).key_from_root(Key["Eb"]).name).to eq("Db")
    end
  end
end
