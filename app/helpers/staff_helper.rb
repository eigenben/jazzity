module StaffHelper
  # Renders staff notation for a list of chords, where each chord is a list
  # of notes such as "Eb/4", or a hash naming the notes on each staff (see
  # VoicedChord#to_staff). Pass clef: :grand for a treble and bass staff.
  def staff_tag(chords, clef: :treble, barlines: false, beats_per_bar: nil, **options)
    tag.div(class: ["staff", options.delete(:class)], data: {
      :controller => "staff",
      :staff_chords_value => chords.to_json,
      :staff_clef_value => clef,
      :staff_barlines_value => barlines,
      :staff_beats_per_bar_value => beats_per_bar
    }.compact, **options)
  end

  # Voiced chords on a grand staff with their symbols, in bars of
  # `beats_per_bar` beats.
  def voiced_staff(chords, beats_per_bar: 4, **options)
    staff_tag(chords, clef: :grand, barlines: true, beats_per_bar: beats_per_bar, **options)
  end

  def chord_staff(chord, **options)
    staff_tag([chord.octavized_notes], **options)
  end

  # Scales and modes are written as a run of single notes.
  def scale_staff(scale, **options)
    staff_tag(scale.octavized_notes.map { |note| [note] }, **options)
  end

  def voicing_staff(voicing, **options)
    staff_tag([voicing.voiced.to_staff], clef: :grand, **options)
  end
end
