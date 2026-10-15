class Scale < ActiveRecord::Base
  extend FriendlyId
  include KeyContext
  include ModeContext
  include Toneable

  has_many :modes, dependent: :destroy

  friendly_id :name, use: :slugged
  include MusicalSlugs

  delegate :chords, to: :main_mode

  validates :name, presence: true

  def to_s
    name
  end

  def title
    if key
      "#{key} #{name} Scale"
    else
      "#{name} Scale"
    end
  end

  def staff_notes
    octavized_notes.map { |n| [n] }
  end

  # Finds a scale by name with an optional key, such as "Bb Major Scale"
  # or "melodic minor in F#", see ScaleName.
  def self.resolve(name)
    target = ScaleName.resolve(name)
    target if target.is_a?(Scale)
  end

  class << self
    alias_method :[], :resolve
  end

  def main_mode
    modes.find_by(mode: 1)
  end

  def symmetric?
    !self.symmetry_index.nil?
  end

  def to_json
    super(methods: [:notes])
  end
end
