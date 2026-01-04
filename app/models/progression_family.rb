class ProgressionFamily < ActiveRecord::Base
  extend FriendlyId

  has_many :progressions

  friendly_id :name, use: :slugged

  def to_s
    name
  end
end
