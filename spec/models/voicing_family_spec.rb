require "spec_helper"

RSpec.describe VoicingFamily, type: :model do
  describe "associations" do
    it { should have_many(:voicings) }
  end
end
