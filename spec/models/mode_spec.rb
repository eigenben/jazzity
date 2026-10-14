require "spec_helper"

RSpec.describe Mode, type: :model do
  context "associations" do
    it { should belong_to(:scale) }
    it { should have_many(:chord_scales) }
    it { should have_many(:chords).through(:chord_scales) }
  end

  context "delegations" do
    it "should delegate notes to tones" do
      expect(described_class.find_by!(name: "Dorian").notes).to eq(["D", "E", "F", "G", "A", "B", "C"])
    end

    it "should delegate octavized_notes to tones" do
      expect(described_class.find_by!(name: "Dorian").octavized_notes.first(2)).to eq(["D/4", "E/4"])
    end
  end

  context "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:mode) }
    it { should validate_presence_of(:scale) }
  end

  it "should expose #to_s as name" do
    expect(described_class.new(:name => "Test").to_s).to eq("Test")
  end

  context "with key context" do
    subject(:mode) { described_class.find_by!(name: "Dorian").in_key_of("Bb") }

    it "should take the notes of its scale in that key" do
      expect(mode.notes).to eq(["C", "D", "Eb", "F", "G", "A", "Bb"])
    end

    it "should start on its own root" do
      expect(mode.mode_key.name).to eq("C")
      expect(mode.title).to eq("C Dorian")
    end
  end
end
