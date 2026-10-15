class Mode < ActiveRecord::Base
  extend FriendlyId
  include KeyContext

  belongs_to :scale

  has_many :chord_scales
  has_many :chords, through: :chord_scales, extend: Chords

  friendly_id :name, use: :slugged
  include MusicalSlugs

  delegate :notes, to: :tones
  delegate :octavized_notes, to: :tones
  delegate :intervals, to: :tones
  delegate :step_names, to: :tones
  delegate :interval_names, to: :tones
  delegate :readable?, to: :tones

  validates :name, presence: true
  validates :mode, presence: true, numericality: true
  validates :scale, presence: true

  def to_s
    name
  end

  def title
    if key
      "#{mode_key} #{name}"
    else
      name
    end
  end

  def information
    super || scale.information
  end

  def main?
    mode == 1
  end

  def mode_key
    Key[notes.first]
  end

  def tones
    scale.tones.in_key_of(key).in_mode(mode)
  end

  def staff_notes
    octavized_notes.map { |n| [n] }
  end

  # Finds a mode by name with the note it starts on, such as "D Dorian" or
  # "Dorian in D", placed in the key of its parent scale, see ScaleName.
  def self.resolve(name)
    target = ScaleName.resolve(name)
    target.is_a?(Scale) ? target.main_mode&.in_key_of(target.key) : target
  end

  class << self
    alias_method :[], :resolve
  end
end
