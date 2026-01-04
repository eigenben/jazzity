class VoicingFamily < ActiveRecord::Base
  extend FriendlyId

  has_many :voicings

  friendly_id :name, use: :slugged

  scope :at_least_tones, ->(n) { where("voicing_tones_count > ?", n) }

  def to_s
    name
  end
end
