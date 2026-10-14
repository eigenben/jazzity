# FriendlyId drops "#" when building slugs, so "Dominant 9" and "Dominant #9"
# would both claim "dominant-9". Spell sharps out instead ("dominant-sharp-9").
module MusicalSlugs
  def normalize_friendly_id(value)
    super(value.to_s.gsub("#", " sharp "))
  end
end
