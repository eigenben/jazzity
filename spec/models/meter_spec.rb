require "spec_helper"

RSpec.describe Meter, type: :model do
  context "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:beats) }
    it { should validate_presence_of(:division) }
  end
  
  it "should expose #to_s as name" do
    expect(described_class.new(:name => "Test").to_s).to eq("Test")
  end
  
  it "should expose #resolve as find_by_name" do
    expect(described_class).to receive(:find_by_name).with("4/4").once
    described_class.resolve("4/4")
  end
end
