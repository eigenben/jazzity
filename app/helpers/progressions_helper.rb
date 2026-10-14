module ProgressionsHelper
  # A chord symbol with real flat and sharp signs, as on a lead sheet:
  # Bbm7b5 is B♭m7♭5 and F#7#11 is F♯7♯11. The signs are wrapped so they
  # can be set in a face that has them.
  def chord_symbol(chord)
    text = chord.lead_sheet_symbol.sub(/\A([A-G])b/, "\\1♭").gsub(/b(?=\d)/, "♭").tr("#", "♯")
    safe_join(text.split(/([♭♯])/).map { |part| part.match?(/\A[♭♯]\z/) ? tag.span(part, class: "accidental") : part })
  end

  # A roman numeral as it's written in an analysis: with flat and sharp
  # signs, and without the m or maj that a chart needs to name a triad
  # (im is i, Imaj is I).
  def roman_numeral(numeral)
    numeral.to_s.sub(/\A([#b]?[iv]+)m(?!aj)/, "\\1").sub(/\A([#b]?[IV]+)maj\z/, "\\1").gsub(/(?<![a-z])b(?=[IViv\d])/, "♭").tr("#", "♯")
  end

  # A chart on one line in roman numerals, as "ii7 | V7 | Imaj7 | %", its
  # first `limit` bars when it's longer.
  def chart_line(chart, limit: 8)
    bars = chart.bars.first(limit).map { |bar| bar.repeat? ? Chart::REPEAT : bar.numerals.map { |numeral| roman_numeral(numeral) }.join(" ") }
    bars.join(" | ") + (chart.bars.size > limit ? " …" : "")
  end

  # What a section of a lead sheet is called by a screen reader: "Section
  # A, bars 1 to 8".
  def lead_sheet_section_label(section)
    bars = section.bars
    [("Section #{section.label}" if section.label), "bars #{bars.first.number} to #{bars.last.number}"].compact.join(", ").upcase_first
  end
end
