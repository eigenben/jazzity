require "spec_helper"

RSpec.describe ChordSequence, type: :model do
  # describe "initializing" do
  #   it "should accept an array of chords and set chord_names" do
  #     described_class.new(["C7", "Bb7"]).chord_names.should == ["C7", "Bb7"]
  #   end

  #   it "should accept a space-separated list of chords and set chord names" do
  #     described_class.new("C7 Bb7").chord_names.should == ["C7", "Bb7"]
  #   end

  #   it "should accept a comma-separated list of chords and set chord names" do
  #     described_class.new("C7,Bb7").chord_names.should == ["C7", "Bb7"]
  #   end
  # end

  # it "should expose name as #to_s" do
  #   described_class.new(:name => "Test").to_s.should == "Test"
  # end

  # it "should expose comma-space-separated chord names as #name" do
  #   described_class.new(:chord_names => ["C7", "Bb7"]).name.should == "C7, Bb7"
  # end

  # it "should expose comma-separated chord names as #to_param" do
  #   described_class.new(:chord_names => ["C7", "Bb7"]).name.should == "C7,Bb7"
  # end

  # it "should expose #resolve"

  # it "should expose #[] as resolve" do
  #   described_class.should_receive(:resolve).with("Test")
  #   described_class["Test"]
  # end

  # context "with key context" do
  #   let(:chord) { described_class.new("C7 Bb7").in_key_of("Bb") }
  #   
  #   it "should expose #title as key and name" do
  #     chord.title.should == "C7, Cmaj7 in Bb"
  #   end
  # end

  # context "with a chord sequence" do

  # end
  # 
  # it "should expose matching progressions as #progressions"

end
