module StaffHelper
  # Renders staff notation for a list of chords, where each chord is a list
  # of notes such as "Eb/4". Pass clef: :grand for a treble and bass staff.
  def staff_tag(chords, clef: :treble, barlines: false, **options)
    tag.div(class: ["staff", options.delete(:class)], data: {
      :controller => "staff",
      :staff_chords_value => chords.to_json,
      :staff_clef_value => clef,
      :staff_barlines_value => barlines
    }, **options)
  end

  def chord_staff(chord, **options)
    staff_tag([chord.octavized_notes], **options)
  end

  # Scales and modes are written as a run of single notes.
  def scale_staff(scale, **options)
    staff_tag(scale.octavized_notes.map { |note| [note] }, **options)
  end

  def voicing_staff(voicing, **options)
    staff_tag([voicing.octavized_notes(3)], clef: :grand, **options)
  end
end
