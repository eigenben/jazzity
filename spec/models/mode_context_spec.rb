require "spec_helper"

RSpec.describe ModeContext do
  subject do
    Class.new do
      include ModeContext
    end.new
  end

  it "places the object in a mode by number" do
    expect(subject.in_mode(3)).to eq(subject)
    expect(subject.mode).to eq(3)
  end

  it "looks up a mode number by name" do
    expect(subject.in_mode("Dorian").mode).to eq(2)
  end

  it "clears the mode" do
    expect(subject.in_mode(3).without_mode.mode).to be_nil
  end
end
