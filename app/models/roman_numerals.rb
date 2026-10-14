# A progression written in roman numerals, as players analyze one: "ii7 V7
# Imaj7", "ii-V-I", "iiø V i", "I vi ii V", "bII7", "#iv°7", "V7/ii", or the
# shorthand "251" and "1-6-2-5". Numerals may be separated by spaces,
# commas, dashes or barlines, and the text may name a key ("ii V I in Eb").
#
#   numerals = RomanNumerals.parse("ii7 V7 Imaj7")
#   numerals.map { |n| [n.degree, n.accidental, n.chord.name] }
#   # => [[2, 0, "Minor 7"], [5, 0, "Dominant 7"], [1, 0, "Major 7"]]
#   numerals.in_key_of("Eb").chords.map(&:lead_sheet_symbol)
#   # => ["Fm7", "Bb7", "Ebmaj7"]
#
# Lowercase numerals are minor, so the quality after one is read as minor
# (ii7 is a minor 7th, ii9 a minor 9th) unless it says otherwise (iiø,
# vii°7). A numeral with no quality is the seventh chord a jazz player
# assumes: maj7 on I and IV (and bIII and bVI), m7 on lowercase numerals,
# m7b5 on vii, and a dominant 7th on everything else.
class RomanNumerals
  include Enumerable
  include KeyContext

  SEPARATORS = /[\s,|–—→-]+/
  DIGITS = /\A[1-7]{3,}\z/
  # The numerals a scale degree stands for in the "251" shorthand.
  DIATONIC = %w[I ii iii IV V vi vii].freeze

  # One chord of the progression: a scale degree (1-7) of the key, raised or
  # lowered by `accidental` semitones, with its chord symbol. A secondary
  # chord such as V7/ii is built on a degree of the chord it leads to.
  class Numeral
    PATTERN = %r{\A(?<accidental>[#b♯♭]?)(?<numeral>VII|VI|V|IV|III|II|I|vii|vi|v|iv|iii|ii|i)(?<quality>[^/]*)(?:/(?<of>.+))?\z}
    NUMERALS = %w[I II III IV V VI VII].freeze
    MINOR_QUALITIES = /\A(?:m|-|min|ø|Ø|°|o|dim|\+|aug)/
    IMPLIED = {:minor => %w[Minor Diminished], :major => %w[Major Dominant Suspended Augmented]}.freeze

    attr_reader :degree, :accidental, :symbol, :of, :text

    def initialize(degree:, accidental:, minor:, symbol:, explicit:, of: nil, text: nil)
      @degree = degree
      @accidental = accidental
      @minor = minor
      @symbol = symbol
      @explicit = explicit
      @of = of
      @text = text
    end

    def self.parse(text)
      match = PATTERN.match(text) or return
      of = match[:of] && (parse(match[:of]) or return)
      numeral = match[:numeral]
      degree = NUMERALS.index(numeral.upcase) + 1
      accidental = {"#" => 1, "♯" => 1, "b" => -1, "♭" => -1}.fetch(match[:accidental], 0)
      minor = numeral == numeral.downcase
      quality = match[:quality]
      symbol = ChordName.find_symbol(quality_for(quality, degree, accidental, minor), bare: true) or return

      new(degree: degree, accidental: accidental, minor: minor, symbol: symbol, explicit: !quality.empty?, of: of, text: text)
    end

    def self.quality_for(quality, degree, accidental, minor)
      if quality.empty?
        default_quality(degree, accidental, minor)
      elsif minor && !MINOR_QUALITIES.match?(quality)
        "m#{quality}"
      else
        quality
      end
    end

    def self.default_quality(degree, accidental, minor)
      if minor
        degree == 7 ? "m7b5" : "m7"
      elsif [[1, 0], [4, 0], [3, -1], [6, -1]].include?([degree, accidental])
        "maj7"
      else
        "7"
      end
    end

    def to_s
      text || "#{{1 => "#", -1 => "b"}[accidental]}#{minor? ? NUMERALS[degree - 1].downcase : NUMERALS[degree - 1]}"
    end

    def minor?
      @minor
    end

    def explicit?
      @explicit
    end

    def chord
      symbol.chord
    end

    # Semitones from the key to the chord's root.
    def index
      (Key::MajorScaleSteps[degree - 1] + accidental + (of ? of.index : 0)) % 12
    end

    # Letters from the key to the chord's root.
    def letter_offset
      (degree - 1 + (of ? of.letter_offset : 0)) % 7
    end

    def root_in(key)
      (key || Key.default).degree_root(index, letter_offset)
    end

    def chord_in(key)
      chord.clone.tap { |chord| chord.key = root_in(key) }
    end

    # Whether a progression's chord is this numeral: on the same root, and
    # of the same kind (minor, dominant...) as the quality written, or as
    # the case of the numeral when no quality is written.
    def matches?(component)
      return false unless component.chord && component.index == index

      if explicit?
        component.chord.chord_quality_id == chord.chord_quality_id
      else
        IMPLIED[minor? ? :minor : :major].include?(component.chord.chord_quality.name)
      end
    end

    # Whether a progression's chord is of the same kind as this numeral's own.
    def exact?(component)
      component.chord&.chord_quality_id == chord.chord_quality_id
    end
  end

  attr_reader :numerals

  def initialize(numerals, key: nil)
    @numerals = numerals
    @key = key
  end

  # The numerals in the text, with the key it names, or nil unless every
  # part of it is a numeral.
  def self.parse(text)
    KeyedQuery.parse(text).each do |reading|
      numerals = numerals_in(reading.text)
      return new(numerals, key: reading.key) if numerals
    end

    nil
  end

  def self.numerals_in(text)
    tokens = text.to_s.strip.split(SEPARATORS).reject(&:empty?)
    tokens = tokens.first.chars if tokens.one? && DIGITS.match?(tokens.first)
    tokens = tokens.map { |token| /\A[1-7]\z/.match?(token) ? DIATONIC[token.to_i - 1] : token }
    return if tokens.empty?

    numerals = tokens.map { |token| Numeral.parse(token) }
    numerals unless numerals.any?(&:nil?)
  end

  private_class_method :numerals_in

  def each(&block)
    numerals.each(&block)
  end

  def size
    numerals.size
  end

  def to_s
    numerals.join(" ")
  end

  def in_key_of(key)
    self.class.new(numerals, key: key.is_a?(Key) ? key : Key[key])
  end

  # The chords in the key, or in C when there's no key.
  def chords
    numerals.map { |numeral| numeral.chord_in(key) }
  end

  def chord_sequence
    ChordSequence.new(chords)
  end

  # Known progressions with these chords, in this key, those whose chords
  # are most often exactly the ones written or assumed first: "ii V" is the
  # major ii-V before the minor one, whose ii is half diminished.
  def progressions
    ranked.map(&:first)
  end

  # The one progression that fits best, if one does.
  def progression
    (best, exact), (_, runner_up) = ranked.first(2)
    best if runner_up.nil? || exact > runner_up
  end

  private

  def ranked
    @ranked ||= Progression.includes(:components => {:chord => :chord_quality}).filter_map do |progression|
      pairs = numerals.zip(progression.components.to_a)
      next unless progression.components.size == size && pairs.all? { |numeral, component| numeral.matches?(component) }

      [progression.in_key_of(key), pairs.count { |numeral, component| numeral.exact?(component) }]
    end.sort_by { |_, exact| -exact }
  end
end
