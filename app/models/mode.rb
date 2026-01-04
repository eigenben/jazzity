class Mode < ActiveRecord::Base
  extend FriendlyId
  include KeyContext
  include Searchable::Model

  belongs_to :scale

  has_many :chord_scales
  has_many :chords, through: :chord_scales, extend: Chords

  friendly_id :name, use: :slugged

  delegate :notes, to: :tones
  delegate :octavized_notes, to: :tones
  delegate :intervals, to: :tones
  delegate :step_names, to: :tones
  delegate :interval_names, to: :tones

  validates :name, presence: true
  validates :mode, presence: true, numericality: true
  validates :scale, presence: true

  define_searchables do
    searchables.create(name: "#{name} Scale")

    Key.primaries.each do |key|
      searchables.create(name: "#{dup.in_key_of(key).mode_key} #{name} Scale", key_name: key.name)
    end
  end

  def to_s
    name
  end

  def title
    if key
      "#{mode_key} #{name}"
    else
      name
    end
  end

  def information
    super || scale.information
  end

  def main?
    mode == 1
  end

  def mode_key
    Key[notes.first]
  end

  def tones
    if self.key
      self.scale.tones.in_mode(self.mode).in_key_of(self.key)
    else
      self.scale.tones.in_mode(self.mode)
    end
  end

  def staff_notes
    octavized_notes.map {|n| [n]}
  end

  def self.resolve(symbol)
    in_key = nil
  
    return nil if symbol.nil?
    symbol = symbol.dup
  
    Key.all.each do |k|
      if symbol.starts_with?(k.name)
        in_key = k
        symbol.gsub!(/^#{k.name}/, '').strip!
        break
      end
    end
  
    mode = find_by(name: symbol)
  
    # Perhaps the matched key was really part of the name, try that:
    if mode.nil? && !in_key.nil?
      symbol = in_key.name + symbol
      mode = all.detect {|s| s.name == symbol}
    end
  
    # If still not found, must be invalid:
    return nil if mode.nil?
  
    mode.key = in_key
    mode
  end

  class << self
    alias_method :[], :resolve
  end

end
