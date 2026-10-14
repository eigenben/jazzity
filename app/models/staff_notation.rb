# Expands {{reference}} markers in descriptive text, such as {{Cmaj7}} or
# {{D Dorian}}, into staff notation.
class StaffNotation
  MARKER = /\{\{(.*?)\}\}/
  NOTATABLE = [NoteSequence, ChordSequence, ChordNoteSequence, Chord, Scale, Mode]

  def self.parse(text)
    text.gsub(MARKER) do
      reference = $1.strip
      notatable = NOTATABLE.lazy.map { |klass| klass[reference] }.find(&:itself)
      notatable ? staff_markup(notatable.staff_notes) : reference
    end
  end

  def self.staff_markup(notes)
    chords = notes.first.is_a?(String) ? [notes] : notes
    %(<div class="staff" data-controller="staff" data-staff-clef-value="grand" data-staff-chords-value="#{ERB::Util.html_escape(chords.to_json)}"></div>)
  end
end
