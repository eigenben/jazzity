class Mode < ActiveRecord::Base
  extend FriendlyId
  include KeyContext
  include Searchable::Model

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

  validates :name, presence: true
  validates :mode, presence: true, numericality: true
  validates :scale, presence: true

  define_searchables do
    searchables.create(name: "#{name} Scale")

    Key.searchable.each do |key|
      searchables.create(name: "#{dup.in_key_of(key).mode_key} #{name} Scale", key_name: key.name)
    end
  end

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

  def self.resolve(symbol)
    return nil if symbol.nil?

    in_key, name = Key.extract(symbol)
    mode = find_by(name: name.strip)

    # Perhaps the matched key was really part of the name, try that:
    if mode.nil? && !in_key.nil?
      in_key = nil
      mode = find_by(name: symbol)
    end

    # If still not found, must be invalid:
    return nil if mode.nil?

    mode.key = in_key
    mode
  end

  class << self
    alias_method :[], :resolve
  end
end
