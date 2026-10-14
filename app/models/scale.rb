class Scale < ActiveRecord::Base
  extend FriendlyId
  include KeyContext
  include ModeContext
  include Toneable
  include Searchable::Model

  has_many :modes, dependent: :destroy

  friendly_id :name, use: :slugged
  include MusicalSlugs

  delegate :chords, to: :main_mode

  validates :name, presence: true

  define_searchables do
    searchables.create(name: "#{name} Scale")

    Key.searchable.each do |key|
      searchables.create(name: "#{key.name} #{name} Scale", key_name: key.name)
    end
  end

  def to_s
    name
  end

  def title
    if key
      "The #{key} #{name} Scale"
    else
      "The #{name} Scale"
    end
  end

  def staff_notes
    octavized_notes.map { |n| [n] }
  end

  def self.resolve(symbol)
    return nil if symbol.nil?

    whole = symbol.gsub(/ Scale/i, "")
    in_key, symbol = Key.extract(whole)
    scale = find_by(name: symbol.strip)

    # Perhaps the matched key was really part of the name, try that:
    if scale.nil? && !in_key.nil?
      in_key = nil
      scale = find_by(name: whole)
    end

    # If still not found, must be invalid:
    return nil if scale.nil?

    scale.key = in_key
    scale
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
