# Works out what key a run of chords is in and what each chord does there,
# the way a player analyzes a lead sheet.
#
#   analysis = HarmonicAnalysis.new(ChordSequence.new("Dm7 G7 Cmaj7 A7").chords)
#   analysis.key.to_s                       # => "C major"
#   analysis.analyzed_chords.map(&:numeral) # => ["ii7", "V7", "Imaj7", "V7/ii"]
#   analysis.patterns.map { |p| p.progression.title }
#   # => ["Major ii-V-I Progression"]
#
# Each major and minor key is scored by how well the chords fit it: a chord
# of the right kind (major, minor, dominant...) on a degree of the key fits
# best, then a dominant that resolves to a chord of the key (a secondary
# dominant or tritone substitute), a chord borrowed from the parallel key,
# and the dominant 7ths of a blues. A V7 or bII7 resolving to the tonic, a
# last chord on the tonic and a first chord on it all count extra, and so
# does the key of a known progression the chords make.
#
# Each chord is then named with a roman numeral in that key: diatonic
# chords by their degree (ii7, bVImaj7 in minor), and the others by what
# they do: V7/ii for a secondary dominant, subV7 for a tritone substitute,
# ii7/V for the ii of a secondary ii-V, and ? for a chord with no clear part.
class HarmonicAnalysis
  NUMERALS = %w[I II III IV V VI VII].freeze
  LOWERCASE_KINDS = %i[minor half_diminished diminished].freeze

  # The kinds of chord on each degree of a key, by semitones from the
  # tonic, the most usual first. Minor keys mix natural, harmonic and
  # melodic minor, as jazz players do.
  DIATONIC = {
    :major => {0 => %i[major], 2 => %i[minor], 4 => %i[minor], 5 => %i[major], 7 => %i[dominant major], 9 => %i[minor], 11 => %i[half_diminished]},
    :minor => {0 => %i[minor], 2 => %i[half_diminished], 3 => %i[major], 5 => %i[minor dominant], 7 => %i[dominant minor], 8 => %i[major dominant], 9 => %i[half_diminished], 10 => %i[dominant], 11 => %i[diminished]}
  }.freeze

  # Chords borrowed from the parallel major or minor key.
  BORROWED = {
    :major => {1 => %i[major], 2 => %i[half_diminished], 3 => %i[major], 5 => %i[minor], 7 => %i[minor], 8 => %i[major dominant], 10 => %i[dominant major]},
    :minor => {0 => %i[major], 2 => %i[minor], 5 => %i[major]}
  }.freeze

  TONIC_KINDS = {:major => %i[major], :minor => %i[minor]}.freeze

  PLAIN_DOMINANTS = ["Dominant 7", "Dominant 9", "Dominant 13"].freeze

  # The families whose progressions are looked for inside the chords.
  PATTERN_FAMILIES = ["Cadences", "Turnarounds", "Cycles & Chains"].freeze

  # A key with its mode.
  Tonality = Data.define(:tonic, :mode) do
    def to_s
      "#{tonic} #{mode}"
    end

    def minor?
      mode == :minor
    end
  end

  # One chord: its roman numeral in the key, what it does there, and the
  # scale that suits it.
  AnalyzedChord = Data.define(:chord, :numeral, :role, :scale) do
    def clear?
      numeral != "?"
    end
  end

  # A known progression found in the chords, from one index to another.
  Pattern = Data.define(:progression, :from, :to, :chords)

  attr_reader :chords

  # `hint` is a key the chords are known to be in, such as the key of a
  # progression they match.
  def initialize(chords, hint: nil)
    @chords = chords.to_a
    @hint = hint
  end

  # The most likely key and mode.
  def key
    @key ||= candidates.max_by { |tonality, score| [score, tonality.minor? ? 0 : 1] }&.first
  end

  # How well each key fits, best first.
  def candidates
    @candidates ||= Key.primaries.flat_map { |tonic| %i[major minor].map { |mode| Tonality.new(tonic: spelled_tonic(tonic), mode: mode) } }
      .map { |tonality| [tonality, score(tonality)] }
      .sort_by { |tonality, score| [-score, tonality.minor? ? 1 : 0] }
  end

  # Each chord with its numeral, role and scale in the key.
  def analyzed_chords
    @analyzed_chords ||= chords.each_index.map do |i|
      numeral, role = label(i)
      AnalyzedChord.new(chord: chords[i], numeral: numeral, role: role, scale: scale_for(i, numeral))
    end
  end

  # The known cadences, turnarounds and chains inside the chords, each in
  # the key it's in there, leaving out any found inside a longer one.
  def patterns
    @patterns ||= begin
      found = pattern_progressions.flat_map { |progression, components| matches(progression, components) }
      found.reject do |pattern|
        found.any? { |other| other != pattern && other.from <= pattern.from && other.to >= pattern.to && (other.to - other.from) > (pattern.to - pattern.from) }
      end.sort_by { |pattern| [pattern.from, -pattern.to] }
    end
  end

  private

  def score(tonality)
    blues = blues?(tonality)

    total = chords.each_index.sum do |i|
      chord_score(i, tonality, blues) + resolution_score(i, tonality, blues)
    end
    total + ends_score(tonality) + (@hint && @hint.index == tonality.tonic.index ? 4 : 0) - (tonality.minor? ? 1 : 0)
  end

  def chord_score(i, tonality, blues)
    offset = offset(chords[i], tonality)
    kind = kind(chords[i])
    kinds = DIATONIC[tonality.mode][offset] || []

    if kinds.first == kind then 2
    elsif kinds.include?(kind) then 1.5
    elsif blues && blues_dominant?(offset, kind, tonality) then 2
    elsif resolves_into_key?(i, tonality) then 1.5
    elsif related_ii?(i) || BORROWED[tonality.mode][offset]&.include?(kind) || blues_dominant?(offset, kind, tonality) then 1
    else 0
    end
  end

  # A V7 or its tritone substitute resolving to the tonic.
  def resolution_score(i, tonality, blues)
    following = chords[i + 1]
    return 0 unless following && kind(chords[i]) == :dominant && offset(following, tonality).zero?
    return 0 unless TONIC_KINDS[tonality.mode].include?(kind(following)) || (blues && kind(following) == :dominant)

    case offset(chords[i], tonality)
    when 7 then 3
    when 1 then 2
    else 0
    end
  end

  # A first chord on the tonic, and a last chord on the tonic (best of all
  # a tonic chord) or on V7.
  def ends_score(tonality)
    return 0 if chords.empty?

    first = offset(chords.first, tonality).zero? ? 1 : 0
    last = case [offset(chords.last, tonality), kind(chords.last)]
    in [0, kind] if TONIC_KINDS[tonality.mode].include?(kind) then 3
    in [0, _] | [7, :dominant] then 1
    else 0
    end
    first + last
  end

  # A blues has dominant 7ths on I and IV.
  def blues?(tonality)
    !tonality.minor? && [0, 5].all? { |offset| chords.any? { |chord| offset(chord, tonality) == offset && kind(chord) == :dominant } }
  end

  def blues_dominant?(offset, kind, tonality)
    !tonality.minor? && kind == :dominant && [0, 5].include?(offset)
  end

  # A dominant resolving down a fifth or a half step to a chord of the key.
  def resolves_into_key?(i, tonality)
    target = resolution_target(i) or return false
    DIATONIC[tonality.mode][offset(target, tonality)]&.include?(kind(target))
  end

  # The chord a dominant resolves to: the next one, when it is a fifth or
  # a half step below.
  def resolution_target(i)
    following = chords[i + 1]
    return unless following && kind(chords[i]) == :dominant

    following if [5, 11].include?(interval(chords[i], following))
  end

  # A minor or half-diminished chord leading to a dominant a fourth above,
  # as the ii of a ii-V.
  def related_ii?(i)
    following = chords[i + 1]
    following && %i[minor half_diminished].include?(kind(chords[i])) && kind(following) == :dominant && interval(chords[i], following) == 5
  end

  def label(i)
    chord = chords[i]
    offset = offset(chord, key)
    kind = kind(chord)
    following = chords[i + 1]

    if DIATONIC[key.mode][offset]&.include?(kind)
      [numeral(chord), diatonic_role(offset, kind)]
    elsif kind == :dominant && following && interval(chord, following) == 5
      secondary(chord, following)
    elsif kind == :dominant && following && interval(chord, following) == 11
      substitute(chord, following)
    elsif related_ii?(i) && secondary_ii_target(i)
      related(chord, i)
    elsif BORROWED[key.mode][offset]&.include?(kind)
      [numeral(chord), "Borrowed from #{key.tonic} #{key.minor? ? "major" : "minor"}"]
    elsif blues_dominant?(offset, kind, key)
      [numeral(chord), "Blues dominant"]
    elsif kind == :diminished
      [numeral(chord), diminished_role(chord, following)]
    elsif related_ii?(i)
      related(chord, i)
    elsif kind == :dominant && (target = (offset + 5) % 12) != 0 && DIATONIC[key.mode][target]
      ["V#{suffix(chord)}/#{degree_numeral(target, DIATONIC[key.mode][target].first)}", "Secondary dominant, unresolved"]
    else
      ["?", "Outside the key (#{numeral(chord)})"]
    end
  end

  def diatonic_role(offset, kind)
    case offset
    when 0 then "Tonic"
    when 7 then kind == :dominant ? "Dominant" : "Diatonic"
    when 2, 5 then "Subdominant"
    else "Diatonic"
    end
  end

  def secondary(chord, target)
    of = bare_numeral(target)
    return [numeral(chord), "Dominant"] if offset(target, key).zero? && offset(chord, key) == 7

    ["V#{suffix(chord)}/#{of}", "Secondary dominant of #{of}"]
  end

  def substitute(chord, target)
    if offset(target, key).zero?
      ["subV#{suffix(chord)}", "Tritone substitute for V7"]
    else
      of = bare_numeral(target)
      ["subV#{suffix(chord)}/#{of}", "Tritone substitute for V7/#{of}"]
    end
  end

  def diminished_role(chord, following)
    case following && interval(chord, following)
    when 1 then "Passing diminished, rising to #{bare_numeral(following)}"
    when 11 then "Passing diminished, falling to #{bare_numeral(following)}"
    else "Passing diminished"
    end
  end

  # The chord other than the tonic that the V of a ii-V resolves to down
  # a fifth, as Dm7 is for Em7b5 A7 Dm7.
  def secondary_ii_target(i)
    target = resolution_target(i + 1)
    target if target && interval(chords[i + 1], target) == 5 && !offset(target, key).zero?
  end

  # The ii of a ii-V that isn't in the key, named after the chord the V
  # resolves to (iiø7/ii in Em7b5 A7 Dm7) or, when it doesn't resolve,
  # after the V itself.
  def related(chord, i)
    if (target = secondary_ii_target(i))
      ["ii#{suffix(chord)}/#{bare_numeral(target)}", "ii of the ii-V to #{bare_numeral(target)}"]
    else
      [numeral(chord), "ii of the ii-V to #{chords[i + 1].lead_sheet_symbol}"]
    end
  end

  def numeral(chord)
    "#{bare_numeral(chord)}#{suffix(chord)}"
  end

  # The degree alone, in the case of the chord's kind: ii, bVII, #iv°.
  # A root spelled as a sharpened degree is named as the flattened one
  # players use (bIII rather than #II), except on a diminished chord,
  # which leads up from the degree below (#i°7).
  def bare_numeral(chord)
    letters = (chord.key.letter_index - key.tonic.letter_index) % 7
    offset = offset(chord, key)
    accidental = ((offset - Key::MajorScaleSteps[letters] + 6) % 12) - 6
    unless accidental.between?(-1, 0) || letters == Key::DegreeLetterOffsets[offset] || (accidental == 1 && kind(chord) == :diminished)
      letters = Key::DegreeLetterOffsets[offset]
      accidental = ((offset - Key::MajorScaleSteps[letters] + 6) % 12) - 6
    end

    roman = NUMERALS[letters]
    roman = roman.downcase if LOWERCASE_KINDS.include?(kind(chord))
    "#{accidental.negative? ? "b" * -accidental : "#" * accidental}#{roman}"
  end

  def degree_numeral(offset, kind)
    letters = Key::DegreeLetterOffsets[offset]
    accidental = offset - Key::MajorScaleSteps[letters]
    roman = NUMERALS[letters]
    roman = roman.downcase if LOWERCASE_KINDS.include?(kind)
    "#{"b" if accidental.negative?}#{"#" if accidental.positive?}#{roman}"
  end

  # The chord's quality as it follows a numeral: 7 after ii (not m7), ø7
  # for a half-diminished chord and °7 for a diminished one.
  def suffix(chord)
    symbol = chord.lead_sheet_symbol.delete_prefix(chord.key.name)
    symbol = symbol.sub(/\Am7b5/, "ø7").sub(/\Adim/, "°").sub(/\Aaug/, "+")
    LOWERCASE_KINDS.include?(kind(chord)) ? symbol.sub(/\Am(?!aj)/, "") : symbol
  end

  # The mode for a chord, placed in the key of its parent scale (D Dorian
  # is in C): for a plain dominant 7th, the one its part calls for, and
  # otherwise the one among the chord's own scales that fits the key best.
  def scale_for(i, numeral)
    chord = chords[i]
    functional_scale(chord, i, numeral) || fitting_scale(chord)
  end

  # Lydian dominant for a tritone substitute and Mixolydian b6 for a
  # dominant resolving to a minor chord, as players choose them.
  def functional_scale(chord, i, numeral)
    return unless PLAIN_DOMINANTS.include?(chord.name)

    target = resolution_target(i)
    name, offset = if numeral.start_with?("subV")
      ["Lydian Dominant", -5]
    elsif target && interval(chord, target) == 5 && %i[minor half_diminished].include?(kind(target))
      ["Mixolydian b6", 5]
    end

    Mode.find_by(:name => name)&.clone&.in_key_of(chord.key.shifted(offset)) if name
  end

  def fitting_scale(chord)
    options = chord.chord_scales.includes(:mode => :scale).map do |chord_scale|
      mode = chord_scale.mode.clone.in_key_of(chord.key.shifted(chord_scale.offset))
      pitches = mode.notes.map { |note| Key[note].index }
      [mode, pitches.count { |pitch| !scale_pitches.include?(pitch) }]
    end

    options.each_with_index.min_by { |(_, misses), i| [misses, i] }&.first&.first
  end

  # The pitches of the key's scale: major, or minor with both its 6ths
  # and 7ths, as jazz uses them.
  def scale_pitches
    @scale_pitches ||= (key.minor? ? [0, 2, 3, 5, 7, 8, 9, 10, 11] : Key::MajorScaleSteps).map { |step| (key.tonic.index + step) % 12 }
  end

  def pattern_progressions
    Progression.includes(:progression_family, :components => {:chord => :chord_quality}).where(:full_tune => false).select do |progression|
      PATTERN_FAMILIES.include?(progression.progression_family&.name)
    end.map { |progression| [progression, progression.changing_components] }
  end

  def matches(progression, components)
    return [] if components.size < 2 || components.size > chords.size

    (0..(chords.size - components.size)).filter_map do |from|
      window = chords[from, components.size]
      key = components.first.key_from_root(window.first.key)
      fits = window.zip(components).all? do |chord, component|
        (chord.key.index - key.index) % 12 == component.index && chord.chord_quality_id == component.chord.chord_quality_id
      end
      Pattern.new(progression: progression.clone.in_key_of((key unless key.main?)), from: from, to: from + components.size - 1, chords: window) if fits
    end
  end

  # The tonic spelled as the chords spell it: as a chord on it is, or
  # else with the letter that names the most of their roots as plain or
  # flattened degrees, preferring the usual name for the key.
  def spelled_tonic(tonic)
    spellings = Key.all.select { |key| key.index == tonic.index && !key.double? }
    spellings.max_by do |spelling|
      [(chords.count { |chord| chord.key == spelling } * 3) + chords.count { |chord| conventional?(chord, spelling) }, Key.standard.include?(spelling) ? 1 : 0]
    end
  end

  def conventional?(chord, tonic)
    offset = (chord.key.index - tonic.index) % 12
    letters = (chord.key.letter_index - tonic.letter_index) % 7
    natural = Key::MajorScaleSteps[letters]
    [natural, (natural - 1) % 12].include?(offset)
  end

  def offset(chord, tonality)
    (chord.key.index - tonality.tonic.index) % 12
  end

  # Semitones up from one chord's root to the next.
  def interval(chord, following)
    (following.key.index - chord.key.index) % 12
  end

  def kind(chord)
    case chord.chord_quality.name
    when "Major" then :major
    when "Minor" then :minor
    when "Dominant", "Suspended" then :dominant
    when "Augmented" then :augmented
    else chord.name == "Diminished 7" ? :diminished : :half_diminished
    end
  end
end
