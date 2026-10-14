class StaffNotation
  def self.parse(text)
    if md = /\{\{(.*)\}\}/.match(text)
      matched = md[1].strip

      staff = nil
      if found = [NoteSequence, ChordSequence, ChordNoteSequence, Chord, Scale, Mode].map { |k| k[matched] }.compact.first
        staff = found.staff_notes
      else
        staff = matched
      end

      text = text.gsub(/\{\{(.*)\}\}/, %(<span class="staff" data-clef="treble,bass" data-width="500" data-height="160" data-staff='#{staff}' />)) if staff
    end
    text
  end
end
