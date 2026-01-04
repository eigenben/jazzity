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
    it "should loop through all symbols and perform case-sensitive based comparison"
  end
  
end
