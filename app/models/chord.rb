class Chord < ActiveRecord::Base
  extend FriendlyId
  include KeyContext
  include Toneable
  include Searchable::Model

  acts_as_tree optional: true
  friendly_id :name, use: :slugged
  include MusicalSlugs

  belongs_to :chord_quality

  has_many :symbols, class_name: "ChordSymbol"
  has_one :primary_symbol, -> { where(primary: true) }, class_name: "ChordSymbol"

  has_many :chord_scales
  has_many :modes, through: :chord_scales
  has_many :voicings
  has_many :voice_leadings_to, through: :voicings
  has_many :voice_leadings_from, through: :voicings

  validates :name, presence: true
  validates :chord_quality, presence: true

  define_searchables do
    searchables.create(name: "#{name} Chord")

    symbols.each { |symbol| searchables.create(name: "#{symbol} Chord") }

    Key.searchable.each do |key|
      searchables.create(name: "#{key.name} #{name} Chord", key_name: key.name)
      symbols.each { |symbol| searchables.create(name: "#{key.name}#{symbol} Chord", key_name: key.name) }

      in_key_of(key).tap do |chord|
        searchables.create(name: chord.notes.join(", "), display_name: "#{chord.notes.join(', ')} (#{title})", key_name: key.name, priority: 2)
      end
    end
  end

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

  # Resolves a chord symbol into a chord.
  # Implementation is somewhat flakey due to the potential ambiguities arising
  # from specifying key and symbols together.
  def self.resolve(symbol)
    return nil if symbol.nil?

    whole = symbol.gsub(/ Chord/i, "")
    in_key, symbol = Key.extract(whole)
    chord_symbol = ChordSymbol[symbol.strip]

    # Perhaps the matched key was really part of the name of the chord, try that:
    if chord_symbol.nil? && !in_key.nil?
      in_key = nil
      chord_symbol = ChordSymbol[whole]
    end

    # If still not found, must be invalid:
    return nil if chord_symbol.nil?

    chord = chord_symbol.chord
    chord.key = in_key unless in_key.nil?
    chord
  end

  class << self
    alias_method :[], :resolve
  end

  def to_json(options = {})
    super({methods: [:notes]}.merge(options))
  end
end
