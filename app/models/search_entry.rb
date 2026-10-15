# Something search can find by name: a chord (by its name and symbol), a
# scale or mode (by its name and the other names it goes by) or a
# progression. Built from the reference data on each search, a few hundred
# names in all, so there's nothing to keep up to date when the seeds change.
class SearchEntry
  KINDS = {:chord => "Chords", :scale => "Scales & modes", :progression => "Progressions"}.freeze

  attr_reader :model, :kind, :names, :symbols

  # `symbols` are a chord's symbols as written, where case matters (m7, M7).
  def initialize(model, kind, names, symbols: [])
    @model = model
    @kind = kind
    @names = names.map { |name| self.class.normalize(name) }.reject(&:empty?).uniq
    @symbols = symbols.reject(&:empty?).uniq
  end

  def self.all
    chords + scales + progressions
  end

  def self.chords
    Chord.includes(:primary_symbol, :chord_quality).map do |chord|
      symbol = chord.primary_symbol.to_s
      symbols = [symbol, symbol.sub(/\Amaj\z/, "").sub(/\Amin/, "m")]
      new(chord, :chord, [chord.name] + symbols, symbols: symbols)
    end
  end

  # A scale under its name and its first mode's, each other mode under its
  # own, and both under any alias ScaleName knows for them.
  def self.scales
    aliases = ScaleName::ALIASES.group_by { |_, name| ScaleName.normalize(name) }.transform_values { |pairs| pairs.map(&:first) }

    Scale.includes(:modes).flat_map do |scale|
      main, *others = scale.modes.sort_by(&:mode)
      names = [scale.name, main&.name].compact
      [new(scale, :scale, names + names.flat_map { |name| aliases.fetch(ScaleName.normalize(name), []) })] +
        others.map { |mode| new(mode, :scale, [mode.name] + aliases.fetch(ScaleName.normalize(mode.name), [])) }
    end
  end

  def self.progressions
    Progression.all.map { |progression| new(progression, :progression, [progression.name]) }
  end

  def self.normalize(text)
    text.to_s.tr("♯♭", "#b").tr("-", " ").squish.downcase
  end

  def group
    KINDS[kind]
  end

  # The chord, scale or progression in a key: for a scale or mode, the key
  # it starts on. Without a key, chords and scales are shown in C (so a
  # mode as it falls in the C major scale, D Dorian), and progressions in
  # their home key.
  def target(key = nil)
    item = model.clone

    case kind
    when :chord then item.in_key_of(key || Key.default)
    when :scale then key ? ScaleName.new(key, item).target : item.in_key_of(Key.default)
    else key ? item.in_key_of(key) : item.in_home_key
    end
  end

  def to_s
    names.first
  end
end
