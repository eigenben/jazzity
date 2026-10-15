class VoicingFamily < ActiveRecord::Base
  extend FriendlyId

  has_many :voicings

  friendly_id :name, use: :slugged

  scope :at_least_tones, ->(n) { where("voicing_tones_count > ?", n) }

  def to_s
    name
  end

  # Whether its voicings are split between the hands, the left hand taking
  # the lowest `left_hand_tones_count` notes.
  def two_handed?
    left_hand_tones_count.present?
  end
end
