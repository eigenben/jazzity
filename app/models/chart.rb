# A progression written out as a lead sheet in roman numerals: bars between
# barlines, the chords in a bar sharing it evenly, % repeating the bar
# before, and optional labels (A:, B:) marking the sections of a form.
# Each numeral is read by RomanNumerals, so "ii7", "V7alt", "#iv°7",
# "bVII7" and "V7/ii" all work.
#
#   chart = Chart.parse("A: | Imaj7 vi7 | ii7 V7 | % |\nB: | III7 | VI7 |")
#   chart.bars.size                 # => 5
#   chart.sections.map(&:label)     # => ["A", "B"]
#   chart.positions_per_bar         # => 2
#   chart.in_key_of("Eb").bars.first.chords.map(&:lead_sheet_symbol)
#   # => ["Ebmaj7", "Cm7"]
class Chart
  include KeyContext

  LABEL = /\A(?<label>[A-Z][A-Za-z0-9']*):\z/
  REPEAT = "%"
  BARLINE = "|"

  class ParseError < ArgumentError; end

  # One bar: the numerals in it, which share it evenly, and its number in
  # the chart (from 1). A bar written % repeats the numerals of the one before.
  class Bar
    attr_reader :numerals, :number

    def initialize(numerals, number:, repeat: false, chart: nil)
      @numerals = numerals
      @number = number
      @repeat = repeat
      @chart = chart
    end

    def repeat?
      @repeat
    end

    def size
      numerals.size
    end

    # The chords of the bar in the chart's key, or in C.
    def chords
      numerals.map { |numeral| numeral.chord_in(@chart&.key) }
    end

    def to_s
      repeat? ? REPEAT : numerals.join(" ")
    end
  end

  # A run of bars, labelled when the chart marks its form.
  Section = Data.define(:label, :bars) do
    def to_s
      [("#{label}:" if label), BARLINE, bars.map { |bar| "#{bar} #{BARLINE}" }].flatten.compact.join(" ")
    end
  end

  attr_reader :sections

  def initialize(sections)
    @sections = sections
  end

  def self.parse(text)
    parse!(text)
  rescue ParseError
    nil
  end

  # Like parse, but says what's wrong with a chart it can't read.
  def self.parse!(text)
    new([]).tap { |chart| chart.send(:read, text.to_s) }
  end

  def bars
    sections.flat_map(&:bars)
  end

  def labelled?
    sections.any?(&:label)
  end

  # The form the section labels spell out, as in "A-A-B-A".
  def form
    sections.map(&:label).join("-") if labelled?
  end

  # The numerals in order, one for each chord written or repeated.
  def numerals
    RomanNumerals.new(bars.flat_map(&:numerals), key: key)
  end

  def chords
    bars.flat_map(&:chords)
  end

  # Positions in a bar: enough for each bar's chords to share it evenly.
  def positions_per_bar
    bars.map(&:size).reduce(1, :lcm)
  end

  # Each chord as the attributes of a ProgressionComponent: its position
  # (from 1, positions_per_bar to the bar), its distance in semitones from
  # the key, the scale degree it's spelled from, and its chord.
  def components
    per_bar = positions_per_bar

    bars.each_with_index.flat_map do |bar, i|
      step = per_bar / bar.size
      bar.numerals.each_with_index.map do |numeral, j|
        {:position => (i * per_bar) + (j * step) + 1, :index => numeral.index, :degree => numeral.letter_offset + 1, :chord => numeral.chord}
      end
    end
  end

  def to_s
    sections.join("\n")
  end

  private

  def read(text)
    @sections = []
    @bars = []
    @tokens = []

    text.gsub(BARLINE, " #{BARLINE} ").split.each do |token|
      if (match = LABEL.match(token))
        close_section
        @label = match[:label]
      elsif token == BARLINE
        close_bar
      else
        @tokens << token
      end
    end
    close_section

    raise ParseError, "The chart has no bars" if sections.empty?
  end

  def close_section
    close_bar
    raise ParseError, "Section #{@label} has no bars" if @label && @bars.empty?

    @sections << Section.new(label: @label, bars: @bars) if @bars.any?
    @bars = []
  end

  def close_bar
    return if @tokens.empty?

    @bars << read_bar(@tokens, bars.size + @bars.size + 1)
    @tokens = []
  end

  def read_bar(tokens, number)
    if tokens == [REPEAT]
      previous = @bars.last || bars.last
      raise ParseError, "Bar #{number} repeats a bar, but there's none before it" unless previous

      return Bar.new(previous.numerals, number: number, repeat: true, chart: self)
    end

    numerals = tokens.map do |token|
      RomanNumerals::Numeral.parse(token) or raise ParseError, "Bar #{number} has “#{token}”, which isn't a roman numeral"
    end
    Bar.new(numerals, number: number, chart: self)
  end
end
