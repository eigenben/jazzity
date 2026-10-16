xml.instruct!
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  xml.url { xml.loc root_url }
  xml.url { xml.loc analysis_url }
  xml.url { xml.loc chords_url }
  xml.url { xml.loc scales_url }

  @progressions.each do |progression|
    xml.url { xml.loc polymorphic_url(progression, action: :practice) }
  end

  Key.standard.each do |key|
    # The chord and scale indexes are written from C whatever the key.
    xml.url { xml.loc polymorphic_url(in_key(key, :progressions)) }

    @chords.each do |chord|
      xml.url { xml.loc polymorphic_url(in_key(key, chord)) }
      chord.voicings.each { |voicing| xml.url { xml.loc polymorphic_url(in_key(key, chord, voicing)) } }
    end

    @scales.each do |scale|
      xml.url { xml.loc polymorphic_url(in_key(key, scale)) }
      # A scale's first mode redirects to the scale.
      scale.modes.reject(&:main?).each { |mode| xml.url { xml.loc polymorphic_url(in_key(key, scale, mode)) } }
    end

    @progressions.each do |progression|
      xml.url { xml.loc polymorphic_url(in_key(key, progression)) }
    end
  end
end
