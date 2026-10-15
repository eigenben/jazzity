# Finds what a musician types. The query is parsed first: notes ("C E G"),
# chords of notes ("D F A C, G B D F"), a progression's name, roman
# numerals ("ii V I in Eb"), a chord sequence ("Dm7 G7 C"), a scale or mode
# ("D Dorian") or a chord symbol ("Bb-7"). Something parsed that way is
# the `destination`, and the page to go straight to.
#
# Anything else is looked up by name among the chords, scales, modes and
# progressions (see SearchEntry), a word at a time, allowing for typos, and
# shown in the key the query names. A misspelled word is corrected first
# ("dorain" is Dorian), and the corrected query parsed again.
class Search
  # A thing found, in a key, and how well its name matched.
  class Result
    attr_reader :target, :entry, :score

    def initialize(target, entry, score)
      @target = target
      @entry = entry
      @score = score
    end

    def kind
      entry&.kind || target.model_name.element.to_sym
    end

    def group
      SearchEntry::KINDS[kind]
    end

    def strong?
      score >= STRONG
    end

    def label
      case target
      when Chord then target.lead_sheet_symbol
      when Scale then target.title.delete_prefix("The ").delete_suffix(" Scale")
      when Mode then target.title
      when Progression then [target.name, ("in #{target.key}" if target.key)].compact.join(" ")
      else target.title
      end
    end

    def detail
      case target
      when Chord then target.name.end_with?("Triad") ? target.title : "#{target.title} chord"
      when Scale, Mode then "scale"
      when Progression then "progression"
      when NoteSequence then "notes"
      when ChordNoteSequence then "chords from notes"
      else "chord sequence"
      end
    end
  end

  STRONG = 70
  PER_GROUP = 8
  ANALYZE = /\A(?:analy[sz]e|analysis(?:\s+of)?)\s+/i
  WORDS = %w[scale mode chord chords progression in on of the key changes].freeze
  # Longer queries aren't read at all, since spelling correction and name
  # matching take longer with every word.
  MAX_LENGTH = 500

  attr_reader :query

  def initialize(query)
    @query = query.to_s.squish
    @query = "" if @query.length > MAX_LENGTH
  end

  # The one thing the query names, if it names one: something it parses as,
  # or the only name it matches.
  def destination
    return @destination if defined?(@destination)

    @destination = parsed || (strong_results.first.target if strong_results.one?)
  end

  # What the query, or failing that the corrected query, parses as.
  def parsed
    return @parsed if defined?(@parsed)

    @parsed = parse(query) || (parse(corrected_query) if corrected?)
  end

  # The query with misspelled words corrected, the same query when nothing needed it.
  def corrected_query
    @corrected_query ||= query.split.map { |word| correct(word) }.join(" ")
  end

  def corrected?
    !corrected_query.casecmp?(query)
  end

  # A line to show with the destination, about what was assumed.
  def note
    if @bass
      "Showing #{@chord_name.to_s.delete_suffix("/#{@bass}")}: slash chords are shown without their bass note (#{@bass})."
    elsif corrected? && destination
      "Showing results for “#{corrected_query}”."
    end
  end

  # Everything the query matches by name, best first.
  def results
    @results ||= begin
      parsed # Roman numerals that match several progressions list them.
      text = corrected? ? corrected_query : query
      found = KeyedQuery.parse(text).flat_map { |reading| matches(reading.text, reading.key) }
      found.concat(@numeral_progressions.each_with_index.map { |progression, i| Result.new(progression, nil, 100 - i) }) if @numeral_progressions
      found.sort_by { |result| [-result.score, result.label.length] }.uniq { |result| [result.target.class, result.target.id] }
    end
  end

  def strong_results
    results.select(&:strong?)
  end

  # Names close to the query, or matching some of its words, for a page
  # with nothing better to show.
  def suggestions_for_nothing_found(limit = 6)
    words = SearchEntry.normalize(corrected_query).split.select { |word| word.length >= 3 }
    close = results.reject(&:strong?)
    partial = entries.filter_map do |entry|
      count = words.count { |word| entry.names.any? { |name| score(name, [word]) >= 40 } }
      Result.new(entry.target, entry, count) if count.positive?
    end

    (close + partial.sort_by { |result| [-result.score, result.label.length] }).uniq(&:label).first(limit)
  end

  # The strong results by group, at most PER_GROUP to a group.
  def grouped_results
    strong_results.group_by(&:group).sort_by { |group, _| SearchEntry::KINDS.values.index(group) }.to_h
  end

  # Suggestions while typing: what the text parses as so far, then names it
  # starts, in the key it names (including a key run into the name, "Ebma").
  def suggestions(limit = 8)
    parsed = parse(query)
    found = [(Result.new(parsed, nil, 1000) if parsed)].compact

    named = KeyedQuery.parse(query).flat_map { |reading| matches(reading.text, reading.key) }.select(&:strong?) + symbols_after_root
    found += named.sort_by { |result| [-result.score, result.label.length] }.uniq { |result| [result.entry.model.class, result.entry.model.id] }

    found.uniq(&:label).first(limit)
  end

  private

  # Chords whose symbol starts with what follows a root typed without a
  # space, as in "Ebma".
  def symbols_after_root
    match = ChordName::ROOT.match(query)
    return [] if match.nil? || query.length == match[0].length || query[match[0].length].match?(/\s/)

    root = Key.parse(match[0]) or return []
    rest = query[match[0].length..]

    entries.select { |entry| entry.symbols.any? { |symbol| symbol.start_with?(rest) } }.map do |entry|
      Result.new(entry.target(root), entry, 90)
    end.select { |result| result.label.start_with?(query) }
  end

  def parse(text)
    return if text.blank?

    analysis_request(text) ||
      ChordNoteSequence[text] ||
      notes(text) ||
      progression_named(text) ||
      numerals(text) ||
      chord_sequence(text) ||
      keyed_scale(text) ||
      chord(text) ||
      unkeyed_scale(text)
  end

  # Changes to analyze, as in "analyze Dm7 G7 Cmaj7 A7" or "analysis of
  # ii V I in Eb": their chord sequence, whose page has the analysis.
  def analysis_request(text)
    changes = text.sub(ANALYZE, "")
    return if changes == text

    chord_sequence(changes) || RomanNumerals.parse(changes)&.chord_sequence
  end

  # Two or more notes; a single note is a chord.
  def notes(text)
    sequence = NoteSequence[text]
    sequence if sequence && sequence.keys.size > 1
  end

  def progression_named(text)
    KeyedQuery.parse(text).each do |reading|
      progression = Progression.where("lower(name) = ?", reading.text.downcase).first
      return progression.in_key_of(reading.key) if progression
    end

    nil
  end

  # Roman numerals go to the progression they match, or to their chords as
  # a sequence when they match none. Several matches are listed instead.
  def numerals(text)
    numerals = RomanNumerals.parse(text)
    return if numerals.nil? || numerals.size < 2

    progressions = numerals.progressions
    return numerals.chord_sequence if progressions.empty?

    @numeral_progressions = progressions
    numerals.progression
  end

  # Two or more chords, not all of them bare roots (that's a set of notes).
  def chord_sequence(text)
    sequence = ChordSequence[text]
    sequence if sequence && !sequence.chord_names.all? { |name| Key.parse(name) }
  end

  def keyed_scale(text)
    name = ScaleName.parse(text)
    name.target if name&.key
  end

  def chord(text)
    name = ChordName.parse(text)
    return unless name&.rooted?

    @chord_name = name
    @bass = name.bass
    name.chord
  end

  # A scale named without a key ("lydian", "whole tone") unless the name
  # also matches chords or progressions ("blues", "altered", "minor").
  def unkeyed_scale(text)
    name = ScaleName.parse(text)
    return if name.nil?

    name.target unless matches(text, nil).any? { |result| result.strong? && result.kind != :scale }
  end

  def matches(text, key)
    words = SearchEntry.normalize(text).split
    return [] if words.empty?

    entries.filter_map do |entry|
      score = entry.names.map { |name| score(name, words) }.max
      Result.new(entry.target(key), entry, score + (key ? 1 : 0)) if score.positive?
    end
  end

  # 100 for the whole name, 90 for its start, 80 when each word starts a
  # word of the name, 70 when the name contains a query of four letters or
  # more; then up to 40 when
  # each word is within a typo or two of a word of the name.
  def score(name, words)
    text = words.join(" ")
    return 100 if name == text
    return 90 if name.start_with?(text)

    name_words = name.split
    return 80 if words.all? { |word| name_words.any? { |name_word| name_word.start_with?(word) } }
    return 70 if text.length > 3 && name.include?(text)

    distances = words.map do |word|
      next 0 if name_words.include?(word)
      next if word.length < 4

      name_words.map { |name_word| DidYouMean::Levenshtein.distance(word, name_word) }.min
    end
    return 0 if distances.any? { |distance| distance.nil? || distance > 2 }

    40 - distances.sum * 10
  end

  def entries
    @entries ||= SearchEntry.all
  end

  def correct(word)
    return word if word.length < 4 || !word.match?(/\A[a-z]+\z/i) || vocabulary.include?(word.downcase)
    return word if ChordName.parse(word)&.rooted?

    DidYouMean::SpellChecker.new(dictionary: vocabulary).correct(word.downcase).first || word
  end

  def vocabulary
    @vocabulary ||= (entries.flat_map(&:names).flat_map(&:split).grep(/\A[a-z]{3,}\z/) + WORDS).to_set
  end
end
