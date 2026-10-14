# Text that may name a key before or after the rest of it, the way people
# type "D Dorian", "dorian D", "Dorian in D", "Eb ii-V-I" or "ii V I in Eb".
#
#   KeyedQuery.parse("ii V I in Eb").map { |reading| [reading.key, reading.text] }
#   # => [[nil, "ii V I in Eb"], [Key["Eb"], "ii V I"]]
#
# The whole text with no key always comes first, so that a name which
# happens to start or end with a letter is still tried as it is.
class KeyedQuery
  TRAILING = /\A(?<rest>.+?)\s+(?:in(?:\s+the\s+key\s+of)?|on|of)\s+(?<key>\S+)(?:\s+(?:major|minor))?\z/i
  LEADING = /\A(?<key>\S+?):?\s+(?<rest>.+)\z/
  LAST = /\A(?<rest>.+)\s+(?<key>\S+)\z/

  attr_reader :key, :text

  def initialize(key, text)
    @key = key
    @text = text
  end

  def to_s
    [text, ("in #{key}" if key)].compact.join(" ")
  end

  # Every reading of the text, without a key first.
  def self.parse(string)
    string = string.to_s.squish
    readings = [new(nil, string)]

    [TRAILING, LEADING, LAST].each do |pattern|
      match = pattern.match(string) or next
      key = Key.parse(match[:key])
      next if key.nil? || key.double?

      readings << new(key, match[:rest].strip)
    end

    readings.uniq { |reading| [reading.key&.name, reading.text] }
  end
end
