class Progression < ActiveRecord::Base
  extend FriendlyId

  include Searchable::Model
  include KeyContext

  friendly_id :name, use: :slugged

  has_many :searchables, as: :model
  belongs_to :progression_family
  belongs_to :meter
  belongs_to :form
  belongs_to :variant_of, class_name: 'Progression'
  has_many :variants, class_name: 'Progression', foreign_key: 'variant_of_id'
  has_many :components, -> { order('progression_components.position') }, class_name: 'ProgressionComponent'

  scope :full_tune, -> { where(full_tune: true) }
  scope :partial, -> { where(full_tune: false) }

  validates :name, presence: true

  define_searchables do
    searchables.create(name: name)
  end

  attr_accessor :chord_voicing_options

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

  def component_durations
    @component_durations ||= begin
      last_i = nil
      final = components.map(&:position).each_with_object([]) do |i, durations|
        durations << (i - last_i) if last_i
        last_i = i
      end

      # final << (bars) ? bars * positions_per_bar - last_i + 1 : 1
      final
    end
  end

  def chords
    components.map do |component|
      component.all_chords_in_key(key)
    end.flatten.compact
  end

  def chord_voicings(voicing_ids = {})
    VoiceLeading.voicings_for_chords(chords, voicing_ids)
  end

  def chord_voicing_notes(voicing_ids = {})
    chord_voicings(voicing_ids).map do |voicing|
      voicing.octavized_notes(3)
    end
  end

  def notes
    chords.map(&:notes)
  end

  def octavized_notes
    chords.map(&:octavized_notes)
  end

  def staff_notes(voicing_ids = {})
    chord_voicing_notes(voicing_ids)
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
end
