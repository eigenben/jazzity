require "spec_helper"

RSpec.describe VoiceLeading, type: :model do
  describe "associations" do
    it { should belong_to(:from_voicing) }
    it { should belong_to(:to_voicing) }
  end
end
