require "spec_helper"

RSpec.describe ProgressionComponent, type: :model do
  describe "associations" do
    it { should belong_to(:progression) }
    it { should belong_to(:chord) }
  end
end
