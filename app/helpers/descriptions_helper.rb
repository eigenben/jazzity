# The titles and descriptions search engines and link previews show for a
# page, written from what the page is about so each one is its own.
module DescriptionsHelper
  DEFAULT_DESCRIPTION = "Explore jazz chords, scales, voicings and progressions in every key, written out in staff notation."

  # Sets the page's description, cut at a word to fit a search result.
  def page_description(text)
    content_for :description, truncate(text.squish, length: 160, separator: " ")
  end

  def description
    content_for(:description).presence || DEFAULT_DESCRIPTION
  end

  # A chord, scale or mode with its key, C included, so that it's named in
  # full: "C Major 7" where the page itself says "Major 7".
  def with_key(record)
    record.key ? record : record.clone.in_key_of(Key.default)
  end

  # "Eb7 Chord (Eb Dominant 7)": the symbol people search for, then the name.
  def chord_page_title(chord)
    "#{chord.short_name} Chord (#{with_key(chord).title})"
  end

  def chord_description(chord)
    scale = chord_modes(chord).first
    parts = [
      "the notes #{chord.notes.join(" ")}",
      (pluralize(chord.voicings.size, "piano voicing") if chord.voicings.any?),
      ("the scales that fit it, like #{scale.title}" if scale)
    ]

    "#{chord.short_name} chord (#{with_key(chord).title}): #{parts.compact.to_sentence}. On the staff and keyboard, ready to play."
  end

  # The modes that fit a chord, each in the key the chord's page shows it in.
  def chord_modes(chord)
    chord.chord_scales.map { |chord_scale| chord_scale.mode.clone.in_key_of((chord.key || Key.default).shifted(chord_scale.offset)) }
  end

  # "F Dorian Scale", or the scale's own title for its first mode.
  def mode_page_title(mode)
    title = mode.main? ? with_key(mode.scale).title : with_key(mode).title
    title.end_with?("Scale") ? title : "#{title} Scale"
  end

  def mode_description(mode)
    chords = mode_chords(mode).first(2).map(&:short_name)
    scale = with_key(mode.scale).title
    name = mode.main? ? "The #{scale}" : "#{with_key(mode).title}, the #{mode.mode.ordinalize} mode of the #{scale}"
    fits = ", and the chords it fits, like #{chords.to_sentence}" if chords.any?

    "#{name}: the notes #{mode.notes.join(" ")}#{fits}. On the staff and keyboard, ready to play."
  end

  # The chords a mode fits, each in the key the mode's page shows it in.
  def mode_chords(mode)
    mode.chord_scales.map { |chord_scale| chord_scale.chord.clone.in_key_of((mode.scale.key || Key.default).shifted(-1 * chord_scale.offset)) }
  end

  def voicing_page_title(voicing)
    "#{voicing.chord.short_name} #{voicing.name} Voicing"
  end

  def voicing_description(voicing, voiced)
    chord = voicing.chord
    hands = ["#{note_names(voiced.bass)} in the left hand", ("#{note_names(voiced.treble)} in the right" if voiced.treble.any?)].compact

    "The #{voicing.name} voicing of #{chord.short_name} (#{with_key(chord).title}) on piano: #{hands.to_sentence}. " \
      "One of #{chord.voicings.size} #{chord.short_name} voicings, ready to play."
  end

  def progression_description(progression)
    symbols = progression.changes.map(&:lead_sheet_symbol)
    changes = symbols.first(8).join(" ") + (symbols.size > 8 ? " …" : "")

    "#{progression.title}: #{changes}. #{progression.summary}"
  end

  private

  def note_names(pitches)
    pitches.map { |pitch| pitch.key.name }.join(" ")
  end
end
