class Progression < ActiveRecord::Base
  extend FriendlyId

  include KeyContext

  friendly_id :name, use: :slugged

  belongs_to :progression_family
  belongs_to :meter
  belongs_to :form
  belongs_to :variant_of, class_name: 'Progression'
  has_many :variants, class_name: 'Progression', foreign_key: 'variant_of_id'
  has_many :components, -> { order('progression_components.position') }, class_name: 'ProgressionComponent', dependent: :destroy

  scope :full_tune, -> { where(full_tune: true) }
  scope :partial, -> { where(full_tune: false) }

  validates :name, presence: true
  validate :chart_fits_the_meter, if: :chart?

  before_save :write_components, if: :will_save_change_to_chart?

  def to_s
    name
  end

  def title
    if key
      "#{name} Progression in #{key}"
    else
      "#{name} Progression"
    end
  end

  def component_index_offsets
    @component_index_offsets ||= begin
      last_i = nil
      components.map(&:index).each_with_object([]) do |i, offsets|
        offsets << (i - last_i) % 12 if last_i
        last_i = i
      end
    end
  end

  # The beats each chord lasts. A progression with a bar count places its
  # chords by position (positions_per_bar to the bar); otherwise each chord
  # gets a bar of its own.
  def chord_beats
    return Array.new(chords.size, beats_per_bar) unless bars

    positions = components.select(&:chord).map(&:position) << bars * positions_per_bar + 1
    positions.each_cons(2).map { |from, to| (to - from) * beats_per_bar / positions_per_bar }
  end

  def chords
    components.map do |component|
      component.all_chords_in_key(key)
    end.flatten.compact
  end

  # The chart the progression is written in, in its key, see Chart.
  def lead_sheet
    @lead_sheet ||= Chart.parse(chart)
    @lead_sheet&.in_key_of(key)
  end

  # The chords as they change, with a chord held over several bars once.
  def changes
    chords.chunk_while { |a, b| a.key == b.key && a.id == b.id }.map(&:first)
  end

  # The components as they change, see #changes.
  def changing_components
    components.to_a.chunk_while { |a, b| a.index == b.index && a.chord_id == b.chord_id }.map(&:first)
  end

  # The chords voiced in a family, see VoiceLeader.
  def voiced_chords(family: nil, overrides: {})
    VoiceLeader.new(chords, family: family, overrides: overrides).voiced_chords
  end

  def notes
    chords.map(&:notes)
  end

  def octavized_notes
    chords.map(&:octavized_notes)
  end

  # The voiced chords for a grand staff, each with its symbol and length in beats.
  def staff_notes(voiced = voiced_chords)
    voiced.zip(chord_beats).map { |chord, beats| chord.to_staff.merge(:beats => beats) }
  end

  def beats_per_bar
    meter&.beats || 4
  end

  def beats
    bars * meter.beats
  end

  def self.resolve(name)
    find_by(name: name)
  end

  class << self
    alias [] resolve
  end

  private

  # Every bar of the chart must split evenly into beats.
  def chart_fits_the_meter
    uneven = Chart.parse!(chart).bars.find { |bar| beats_per_bar % bar.size != 0 }
    errors.add(:chart, "has #{uneven.size} chords in bar #{uneven.number}, which can't share #{beats_per_bar} beats evenly") if uneven
  rescue Chart::ParseError => e
    errors.add(:chart, e.message)
  end

  # Writes the chart out as components, a chord to each position, and
  # counts its bars.
  def write_components
    @lead_sheet = nil
    written = Chart.parse!(chart)
    self.bars = written.bars.size
    self.positions_per_bar = written.positions_per_bar
    self.components = written.components.map { |attributes| ProgressionComponent.new(attributes) }
  end
end
