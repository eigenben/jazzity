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

  # Names that already say what kind of thing they are, so "Progression"
  # isn't added to their titles: "Rhythm Changes in F", not "Rhythm Changes
  # Progression in F", but still "Major ii-V-I Progression in F".
  SELF_DESCRIBING = /\b(Cadence|Turnaround|Changes|Blues|Form|AABA|Vamp|Chain|Cliché|Dominants)\b/

  scope :full_tune, -> { where(full_tune: true) }
  scope :partial, -> { where(full_tune: false) }

  validates :name, presence: true
  validate :chart_fits_the_meter, if: :chart?

  before_save :write_components, if: :will_save_change_to_chart?

  def to_s
    name
  end

  def title
    title = name.match?(SELF_DESCRIBING) ? name : "#{name} Progression"
    key ? "#{title} in #{key}" : title
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

  # The progression this is a variation on and its other variations, or
  # this progression's own variations, in its key.
  def variations
    parent = variant_of || self
    ([parent] + parent.variants.to_a).reject { |progression| progression.id == id }.map { |progression| progression.in_key_of(key) }
  end

  # The progression in each of the twelve keys, starting from its own and
  # going round them in a practice order, see Key.practice_order.
  def in_every_key(order = "fourths")
    Key.practice_order(order, key || Key.default).map { |key| clone.in_key_of(key) }
  end

  # The changes as a chord sequence in the progression's key, to analyze.
  def chord_sequence
    ChordSequence.in_key(changes, key)
  end

  # The ways its changes can be reharmonized, see Reharmonization.
  def reharmonizations
    Reharmonization.all(changes, key: key)
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

  # The voiced chords for a player, each with its length in beats.
  def playback(voiced = voiced_chords)
    voiced.zip(chord_beats).map { |chord, beats| chord.to_playback.merge(:beats => beats) }
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
