module ApplicationHelper
  STAFF_ATTRIBUTES = %w[data-controller data-staff-clef-value data-staff-chords-value]

  def navigation_link_to(name, path, controllers)
    current = Array(controllers).any? { |c| controller.is_a?(c) }
    link_to name, path, :aria => {:current => ("page" if current)}
  end

  # The address search engines should file this page under: without its
  # query, and without /keys/C, since C pages live at the unprefixed URL.
  def canonical_url
    request.base_url + request.path.sub(%r{\A/keys/C(?=/)}, "")
  end

  # Builds a polymorphic path in the given key. C is the reference key, so
  # its pages live at the unprefixed URL.
  def in_key(key, *parts)
    [(key unless key.nil? || key.main?), *parts].compact
  end

  # Notes as tiles, with `intervals` between them (the interval from each note
  # to the next) and, with `root`, the first picked out.
  def note_tiles(notes, intervals: [], root: false)
    tiles = notes.each_with_index.flat_map do |note, i|
      interval = intervals[i] if i < notes.size - 1
      [tag.span(note, class: ["note-tile", ("note-tile-root" if root && i.zero?)]), (tag.span(interval, class: "note-interval") if interval)]
    end
    tag.span(safe_join(tiles.compact), class: "note-tiles")
  end

  # Renders a Textile description, expanding {{Cmaj7}}-style references into staff notation.
  def text_to_html(text)
    html = RedCloth.new(StaffNotation.parse(text.to_s)).to_html
    sanitize html, attributes: Rails::HTML5::SafeListSanitizer.allowed_attributes + STAFF_ATTRIBUTES
  end

  # Links to chords, named by their short names (Dmin7) or, with
  # `lead_sheet`, by their symbols as a lead sheet writes them (Dm7).
  def links_to_chords(chords, separator = ", ", lead_sheet: false)
    safe_join(chords.map { |chord| link_to(lead_sheet ? chord_symbol(chord) : chord.short_name, in_key(chord.key, chord)) }, separator)
  end

  def link_to_search_example(name)
    link_to name, search_path(name)
  end

  # The families offered for voicing a progression, with a short label and a
  # line saying how each is played.
  VOICING_FAMILIES = {
    "4-Note Rootless (Type I/II)" => ["Rootless", "Four-note rootless voicings in their two forms, with the 3rd or the 7th on the bottom, played over the root."],
    "Rootless 3-Note Shells" => ["Shells", "Three-note rootless voicings: the 3rd and 7th with one more tone, played over the root."],
    "Guide Tones" => ["Guide tones", "Just the 3rd and 7th, the notes that define each chord, played over the root."],
    "Rooted Guide Tones" => ["Rooted shells", "The root, 3rd and 7th in the left hand, as bebop pianists comped."],
    "4-Note Rooted" => ["Rooted", "Four-note voicings with the root on the bottom or inside, in the left hand."]
  }.freeze

  def voicing_family_choices
    families = VoicingFamily.where(:name => VOICING_FAMILIES.keys).index_by(&:name)
    VOICING_FAMILIES.filter_map { |name, (label, _)| [families[name], label] if families[name] }
  end

  def voicing_family_description(family)
    VOICING_FAMILIES.dig(family&.name, 1)
  end

  # The voicings of a chord grouped by family, after a default that leaves
  # the chord to the voice leader (naming the voicing it picked).
  def voicing_options_for_select(voiced, position)
    selected = voicing_choices[position.to_s].to_s
    auto = selected.to_i.positive? ? "Voice-led" : "Voice-led: #{voiced.name}"
    groups = voiced.chord.voicings.includes(:voicing_family).group_by(&:voicing_family).map do |family, voicings|
      [family.name, voicings.map { |voicing| [voicing.name, voicing.id.to_s] }]
    end

    options_for_select([[auto, ""]], selected) + grouped_options_for_select(groups, selected)
  end

  # The voicing family and picks on the current page, to keep when moving
  # to another key.
  def voicing_params
    {:family => voicing_family_slug, :v => voicing_choices.compact_blank.presence}.compact
  end
end
