class Chord < ActiveRecord::Base
  extend FriendlyId
  include KeyContext
  include Toneable

  acts_as_tree optional: true
  friendly_id :name, use: :slugged
  include MusicalSlugs

  belongs_to :chord_quality

  has_many :symbols, class_name: "ChordSymbol"
  has_one :primary_symbol, -> { where(primary: true) }, class_name: "ChordSymbol"

  has_many :chord_scales
  has_many :modes, through: :chord_scales
  has_many :voicings

  validates :name, presence: true
  validates :chord_quality, presence: true

  def to_s
    name
  end

  def short_name
    "#{key || Key.default}#{primary_symbol}"
  end

  # The symbol as it's written over the staff on a lead sheet: a plain letter
  # for a major triad and "m" for minor, as in C, Dm7 and F#m7b5.
  def lead_sheet_symbol
    "#{key || Key.default}#{primary_symbol.to_s.sub(/\Amaj\z/, "").sub(/\Amin/, "m")}"
  end

  def title
    if key
      "#{key} #{name}"
    else
      name
    end
  end

  def symbol_names
    symbols.map { |s| key.to_s + s.name }
  end
  def main_symbol_name
    symbol_names.first
  end
  def other_symbol_names
    symbol_names[1..-1] || []
  end

  # Resolves a chord symbol such as "Ebmaj7", "F#-7" or "C7(b9)" into a
  # chord in its root's key, see ChordName.
  def self.resolve(symbol)
    ChordName.resolve(symbol)
  end

  class << self
    alias_method :[], :resolve
  end

  def to_json(options = {})
    super({methods: [:notes]}.merge(options))
  end
end
