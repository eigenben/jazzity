require "spec_helper"

RSpec.describe Key, type: :model do
  it "should expose #to_s as name"
  
  it "should expose #default as the key of C" do
    expect(described_class.default.name).to eq("C")
  end
  
  it "should expose primary keys around the cycle" do
    expect(described_class.primaries.map(&:name)).to match(["C", "F", "Bb", "Eb", "Ab", "Db", "Gb", "B", "E", "A", "D", "G"])
  end
  
  describe "#enharmonic_with?" do
    
  end
  
  describe "deindexing" do
    
  end
  
  describe "hash access" do
    it "should look up by name"
    it "should look up by index"
  end
end
