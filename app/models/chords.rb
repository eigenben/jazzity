module Chords
  # Formats chord collection
  def to_s(format = :symbols)
    case format
    when :symbols then symbols.join(', ')
    when :names then names.join(', ')
    end
  end

  # Returns array of chord symbols only
  def symbols
    self.map { |c| "#{c.key.name if c.key}#{c.primary_symbol.name}" }
  end

  # Returns array of chord names only
  def names
    self.map { |c| "#{c.key.name if c.key} #{c.name}".strip }
  end
end
