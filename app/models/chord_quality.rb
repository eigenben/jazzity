class ChordQuality < ActiveRecord::Base
  extend FriendlyId

  has_many :chords

  friendly_id :name, use: :slugged

  validates :name, presence: true
  validates :code, presence: true

  def to_s
    name
  end

  def self.resolve(name)
    find_by(name: name)
  end

  class << self
    alias_method :[], :resolve
  end

end
