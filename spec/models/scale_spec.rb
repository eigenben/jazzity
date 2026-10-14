require "spec_helper"

RSpec.describe Scale, type: :model do
  context "associations" do
    it { should have_many(:modes).dependent(:destroy) }
  end

  context "validations" do
    it { should validate_presence_of(:name) }
  end

  describe ".resolve" do
    it "finds a scale by name in the given key" do
      scale = described_class["Eb Major Scale"]
      expect(scale.name).to eq("Major")
      expect(scale.notes).to eq(["Eb", "F", "G", "Ab", "Bb", "C", "D"])
    end

    it "finds a scale in C when no key is given" do
      expect(described_class["Major"].notes).to eq(["C", "D", "E", "F", "G", "A", "B"])
    end

    it "returns nil for unknown scales" do
      expect(described_class["Imaginary Scale"]).to be_nil
    end
  end

  it "includes the key in its title" do
    expect(described_class["Eb Major"].title).to eq("The Eb Major Scale")
    expect(described_class["Major"].title).to eq("The Major Scale")
  end

  it "exposes the first mode as its main mode" do
    expect(described_class["Major"].main_mode.name).to eq("Ionian")
  end

  it "renders each note separately on the staff" do
    expect(described_class["Eb Major"].staff_notes.first(2)).to eq([["Eb/4"], ["F/4"]])
  end
end
