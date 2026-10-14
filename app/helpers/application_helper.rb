module ApplicationHelper
  STAFF_ATTRIBUTES = %w[data-controller data-staff-clef-value data-staff-chords-value]

  def navigation_link_to(name, path, controllers)
    current = Array(controllers).any? { |c| controller.is_a?(c) }
    link_to name, path, :aria => {:current => ("page" if current)}
  end

  # Builds a polymorphic path in the given key. C is the reference key, so
  # its pages live at the unprefixed URL.
  def in_key(key, *parts)
    [(key unless key.nil? || key.main?), *parts].compact
  end

  # Renders a Textile description, expanding {{Cmaj7}}-style references into staff notation.
  def text_to_html(text)
    html = RedCloth.new(StaffNotation.parse(text.to_s)).to_html
    sanitize html, attributes: Rails::HTML5::SafeListSanitizer.allowed_attributes + STAFF_ATTRIBUTES
  end

  def links_to_chords(chords, separator = ", ")
    safe_join(chords.map { |chord| link_to(chord.short_name, in_key(chord.key, chord)) }, separator)
  end

  def link_to_search_example(name)
    link_to name, search_path(name)
  end

  def voicing_options_for_select(chord, position)
    selected = voicing_choices[position.to_s]
    lead = position.zero? ? "Any voicing" : "Voice-led from previous chord"

    options_for_select([[lead, "<"]], selected) + options_from_collection_for_select(chord.voicings, :id, :name, selected)
  end
end
