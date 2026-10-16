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

  # The symbol as players write it, on a lead sheet or anywhere else: a
  # plain letter for a major triad and "m" for minor, as in C, Dm7 and F#m7b5.
  def short_name
    "#{key || Key.default}#{primary_symbol.to_s.sub(/\Amaj\z/, "").sub(/\Amin/, "m")}"
  end
  alias_method :lead_sheet_symbol, :short_name

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

  # Each note with what it is to the root: Eb7 is Eb (root), G (major
  # 3rd), Bb (5th) and Db (minor 7th).
  def degrees
    notes.zip(tones.degree_names)
  end

  # The 3rd and 7th (or the 6th of a 6th chord) as [note, degree] pairs,
  # the notes that say what kind of chord it is. Nil for a chord without
  # both, such as a triad or a sus chord.
  def guide_tones
    third = degrees.find { |_, degree| degree.end_with?("3rd") }
    seventh = degrees.find { |_, degree| degree.end_with?("7th") } || degrees.find { |_, degree| degree == "6th" }
    [third, seventh] if third && seventh
  end

  # The dominant 7th a tritone away, which has the same 3rd and 7th the
  # other way up and can stand in for this chord: A7 for Eb7. Nil unless
  # this chord has a major 3rd and a minor 7th.
  def tritone_substitute
    return unless (guide_tones || []).map(&:last) == ["major 3rd", "minor 7th"]

    Chord.find_by(name: "Dominant 7")&.in_key_of(Key.from_index((key || Key.default).index + 6))
  end

  # The progressions this chord is played in, as a hash from the numeral
  # it's written as to the first progression with it (each progression
  # once), in the key that puts this chord there: Eb7 is the V7 of the
  # major ii-V in Ab and the bII7 of the tritone sub ii-V-I in D.
  def roles(progressions = Progression.order(:id))
    root = key || Key.default

    progressions.each_with_object({}) do |progression, roles|
      progression.lead_sheet&.numerals&.each do |numeral|
        next if numeral.chord.id != id || roles.key?(numeral.to_s) || roles.each_value.any? { |role| role.id == progression.id }

        progression_key = root.shifted(-numeral.index, -numeral.letter_offset)
        next unless Key.standard.include?(progression_key) && numeral.root_in(progression_key) == root

        roles[numeral.to_s] = progression.clone.in_key_of(progression_key)
      end
    end
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
