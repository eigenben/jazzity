# A chord symbol as a musician writes it: a root, the quality and its
# extensions, and optionally a bass note after a slash.
#
#   ChordName.parse("Bb-7").chord.title   # => "Bb Minor 7"
#   ChordName.parse("C7(b9)").to_s        # => "C7b9"
#   ChordName.parse("C7/E").bass          # => Key["E"]
#   ChordName.parse("Eb").chord.title     # => "Eb Major Triad"
#
# The root's letter may be in either case and takes # or b (or ♯ and ♭).
# The quality is matched against the chord symbols as written first, so
# case-sensitive symbols keep their meaning (Cm7 is minor, CM7 major), then
# against chord names ("C Major 7"), and finally after rewriting the common
# alternative spellings: -, mi and min for m; ø for m7b5; ° and o for dim;
# Δ, ^, ma and M for maj; + for aug; dom for a dominant; and dropping spaces
# and parentheses. A bare root is a major triad. Without a root the chord has
# no key, as in ChordName.parse("maj7").
class ChordName
  ROOT = /\A([A-Ga-g])([#b♯♭]?)/
  BASS = %r{\A(?<chord>.+)/(?<bass>[A-Ga-g][#b♯♭]?)\z}

  # Rewrites of the start of a quality, the first that matches wins.
  LEADING = [
    [/\A[øØ]7?/, "m7b5"],
    [/\A(?:major|Major|MAJOR|maj|Maj|MAJ|ma|Ma|MA|Δ|\^|M(?!i))/, "maj"],
    [/\A(?:minor|Minor|MINOR|min|Min|MIN|mi|Mi|m|-)/, "m"],
    [/\A(?:dim|Dim|DIM|o|°|º)/, "dim"],
    [/\A(?:aug|Aug|AUG|\+)/, "aug"],
    [/\A(?:dom|Dom|DOM)\z/, "7"],
    [/\A(?:dom|Dom|DOM)/, ""],
    [/\Aalt\z/i, "7alt"]
  ].freeze

  attr_reader :root, :symbol, :bass, :quality

  def initialize(root:, symbol:, bass: nil, quality: "")
    @root = root
    @symbol = symbol
    @bass = bass
    @quality = quality
  end

  def self.parse(text)
    text = text.to_s.strip.sub(/\s*chord\z/i, "")
    return if text.empty?

    bass = nil
    if (match = BASS.match(text))
      text = match[:chord]
      bass = Key.parse(match[:bass])
    end

    readings(text).each do |root, quality|
      symbol = find_symbol(quality, bare: !root.nil?)
      return new(root: root, symbol: symbol, bass: bass, quality: quality) if symbol
    end

    nil
  end

  # The chord a chord name resolves to, see Chord.resolve.
  def self.resolve(text)
    parse(text)&.chord
  end

  # The chord symbol for a quality such as "m7", "-7", "ø" or "Major 7".
  # An empty quality is a major triad when `bare` is set.
  def self.find_symbol(quality, bare: false)
    quality = quality.to_s.strip
    return if quality.empty? && !bare

    symbols = ChordSymbol.includes(:chord).to_a
    exact = symbols.find { |symbol| symbol.case_sensitive? ? symbol.name == quality : symbol.name.casecmp?(quality) }
    exact || named(quality) || index(symbols)[normalize(quality)]
  end

  # The common spellings of a quality rewritten in one way: "-7" and "min7"
  # become "m7", "Δ7" and "^7" become "maj7", "7(b9)" becomes "7b9".
  def self.normalize(quality)
    text = quality.to_s.tr("♯♭", "#b").tr("–−", "-").gsub(/[\s(),]/, "").gsub(/altered/i, "alt")
    return "maj" if text.empty?

    pattern, replacement = LEADING.find { |leading, _| leading.match?(text) }
    head, rest = pattern ? [replacement, text.sub(pattern, "")] : ["", text]
    rest = rest.gsub(/major|Major|MAJ|Maj|maj|Δ|\^|M/, "maj").gsub(/-(?=\d)/, "b").gsub(/\+(?=\d)/, "#")

    head + rest
  end

  # Ways to split text into a root and a quality: the root with its
  # accidental, then without it (in case the b belongs to the quality), then
  # no root at all.
  def self.readings(text)
    match = ROOT.match(text)
    return [[nil, text]] unless match

    letter = match[1].upcase
    readings = []
    readings << [Key.from_name(letter + match[2].tr("♯♭", "#b")), text[2..]] unless match[2].empty?
    readings << [Key.from_name(letter), text[1..]]
    readings << [nil, text]
  end

  def self.named(quality)
    Chord.includes(:primary_symbol).find { |chord| chord.name.casecmp?(quality.squish) }&.primary_symbol
  end

  # Each symbol under its normalized spelling. Where several symbols share a
  # spelling, the one already written that way wins (maj over M and Δ).
  def self.index(symbols)
    symbols.sort_by { |symbol| [normalize(symbol.name) == symbol.name ? 0 : 1, symbol.primary? ? 0 : 1] }.each_with_object({}) do |symbol, index|
      index[normalize(symbol.name)] ||= symbol
    end
  end

  private_class_method :readings, :named, :index

  def to_s
    "#{root}#{symbol unless bare?}#{"/#{bass}" if bass}"
  end

  def bare?
    quality.strip.empty?
  end

  def rooted?
    !root.nil?
  end

  def chord
    symbol.chord.clone.tap { |chord| chord.key = root }
  end
end
