require "spec_helper"

RSpec.describe TuneProgression, type: :model do
  describe "associations" do
    it { should belong_to(:tune) }
    it { should belong_to(:progression) }
  end
end
