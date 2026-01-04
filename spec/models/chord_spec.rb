RSpec.describe Chord, type: :model do
  context "associations" do
    it { should belong_to(:chord_quality) }
    it { should have_many(:chord_scales) }
    it { should have_many(:modes).through(:chord_scales) }
    it { should have_many(:voicings) }
  end
  
  context "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:chord_quality) }
  end
  
  it "should expose name as #to_s" do
    expect(Chord.new(:name => "Test").to_s).to eq("Test")
  end
  
  context "without key context" do
    subject { Chord.new(:name => "Test") }
    
    it "should expose #title as name" do
      expect(subject.title).to eq("Test")
    end
  end
  
  context "with key context" do
    subject { Chord.new(:name => "Test").in_key_of("Bb") }
    
    it "should expose #title as key and name" do
      expect(subject.title).to eq("Bb Test")
    end
  end
end

