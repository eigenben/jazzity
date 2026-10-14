require 'spec_helper'

RSpec.describe Progression, type: :model do
  it { should belong_to(:progression_family) }
  it { should belong_to(:meter) }
  it { should belong_to(:form) }
  it { should have_many(:components) }

  describe 'scopes' do
    it 'should scope full_tune' do
      expect(described_class.full_tune.pluck(:name)).to include('Original Rhythm Changes')
    end

    it 'should scope partial' do
      expect(described_class.partial.pluck(:name)).to include('Major ii-V-I')
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  it 'should expose name as #to_s' do
    expect(described_class.new(name: 'Test').to_s).to eq('Test')
  end

  it 'should expose beats as bars times meter beats' do
    described_class.new(bars: 16).tap do |progression|
      expect(progression).to receive(:meter).and_return(double(:beats, beats: 4))
      expect(progression.beats).to eq(16 * 4)
    end
  end

  describe "chart" do
    it "writes the chart out as components and counts its bars" do
      progression = described_class.create!(name: "Chart test", meter: Meter["4/4"], chart: "| ii7 V7 | Imaj7 | % |")

      expect(progression.bars).to eq(3)
      expect(progression.positions_per_bar).to eq(2)
      expect(progression.components.map { |c| [c.position, c.index, c.degree] }).to eq([[1, 2, 2], [2, 7, 5], [3, 0, 1], [5, 0, 1]])
      expect(progression.chord_beats).to eq([2, 2, 4, 4])
      expect(progression.changes.map(&:lead_sheet_symbol)).to eq(%w[Dm7 G7 Cmaj7])
      expect(progression.in_key_of(Key["Eb"]).lead_sheet.chords.map(&:lead_sheet_symbol)).to eq(%w[Fm7 Bb7 Ebmaj7 Ebmaj7])
    ensure
      progression&.destroy
    end

    it "rewrites the components when the chart changes" do
      progression = described_class.create!(name: "Chart test", chart: "| ii7 | V7 |")
      progression.update!(chart: "| iv7 | bVII7 | Imaj7 |")

      expect(progression.reload.chords.map(&:lead_sheet_symbol)).to eq(%w[Fm7 Bb7 Cmaj7])
      expect(ProgressionComponent.where(progression_id: progression.id).count).to eq(3)
    ensure
      progression&.destroy
    end

    it "must be readable, with bars that share the meter's beats evenly" do
      expect(described_class.new(name: "Bad", chart: "| ii7 | nope |")).not_to be_valid
      expect(described_class.new(name: "Uneven", meter: Meter["4/4"], chart: "| ii7 V7 Imaj7 |").tap(&:validate).errors[:chart]).to include(/can't share 4 beats evenly/)
    end
  end

  it 'should delegate resolve to find_by' do
    expect(described_class).to receive(:find_by).with(name: 'Test')
    described_class.resolve('Test')
  end

  it 'should delegate [] to find_by' do
    expect(described_class).to receive(:find_by).with(name: 'Test')
    described_class['Test']
  end
end
