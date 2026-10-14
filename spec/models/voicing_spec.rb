require 'spec_helper'

RSpec.describe Voicing, type: :model do
  describe 'associations' do
    it { should belong_to(:voicing_family) }
    it { should belong_to(:chord) }
    it { should belong_to(:upper_structure_chord) }
  end
end
