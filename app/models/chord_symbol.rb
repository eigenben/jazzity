class ChordSymbol < ActiveRecord::Base
  belongs_to :chord

  validates :name, :presence => true
  validates :chord, :presence => true

  def to_s
    name
  end

  # Finds a chord symbol
  def self.resolve(symbol)
    all.detect do |cs|
      cs.case_sensitive? ? (cs.name == symbol) : (cs.name.downcase == symbol.downcase)
    end
  end

  class << self
    alias_method :[], :resolve
  end
end
