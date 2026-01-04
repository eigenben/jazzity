require "spec_helper"

RSpec.describe ProgressionFamily, type: :model do
  describe "associations" do
    it { should have_many(:progressions) }
  end
end

