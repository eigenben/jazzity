class Form < ActiveRecord::Base
  extend FriendlyId

  has_many :progressions

  friendly_id :name, use: :slugged

  validates :name, presence: true

  def to_s
    name
  end

  def self.resolve(name)
    find_by(name: name)
  end

  class << self
    alias [] resolve
  end
end
