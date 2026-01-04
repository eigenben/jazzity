require 'spec_helper'

RSpec.describe Form, type: :model do
  context 'associations' do
    it { should have_many(:progressions) }
    it { should have_many(:tunes) }
  end

  context 'validations' do
    it { should validate_presence_of(:name) }
  end

  it 'should expose #resolve as find_by' do
    expect(described_class).to receive(:find_by).with(name: 'Blues').once
    described_class.resolve('Blues')
  end
end
