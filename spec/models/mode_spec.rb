require "spec_helper"

RSpec.describe Mode, type: :model do
  context "associations" do
    it { should belong_to(:scale) }
    it { should have_many(:chord_scales) }
    it { should have_many(:chords).through(:chord_scales) }
  end
  
  context "delegations" do
    it "should delegate notes to tones"
    it "should delegate octavized_notes to tones"
  end
  
  context "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:mode) }
    it { should validate_presence_of(:scale) }
  end
  
  it "should expose #to_s as name" do
    expect(described_class.new(:name => "Test").to_s).to eq("Test")
  end
  
  # TODO
  
end
