require "spec_helper"

RSpec.describe Search do
  def results_for(query)
    described_class.new(query).all
  end

  it "matches searchable names" do
    expect(results_for("Dorian").map(&:to_s)).to include("D Dorian Scale", "Eb Dorian Scale")
  end

  it "recognizes chord sequences" do
    expect(results_for("Dm7 G7 Cmaj7").map(&:target)).to contain_exactly(an_instance_of(ChordSequence))
  end

  it "recognizes note sequences" do
    expect(results_for("C E G").map(&:target)).to include(an_instance_of(NoteSequence))
  end

  it "labels sequence results with the sequence itself" do
    expect(results_for("Dm7 G7 Cmaj7").map(&:to_s)).to eq(["Dm7, G7, Cmaj7"])
  end

  it "returns nothing for unrecognized queries" do
    expect(results_for("qwertyuiop")).to be_empty
  end
end
