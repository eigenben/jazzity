class Voicing < ActiveRecord::Base
  extend FriendlyId

  include KeyContext
  include OctaveContext
  include Toneable

  acts_as_tree optional: true
  friendly_id :name, use: :scoped, scope: :chord
  include MusicalSlugs

  belongs_to :voicing_family
  belongs_to :chord
  has_many :voice_leadings_to, class_name: "VoiceLeading", foreign_key: "to_voicing_id"
  has_many :voice_leadings_from, class_name: "VoiceLeading", foreign_key: "from_voicing_id"
  belongs_to :upper_structure_chord, class_name: "Chord"

  validates :name, presence: true

  def to_s
    name
  end

  def title
    if key
      "#{name} Voicing in #{key}"
    else
      "#{name} Voicing"
    end
  end

  def chord_in_key
    chord.in_key_of(key)
  end

  # This voicing played on its chord, over the root when it's rootless.
  def voiced
    VoiceLeader.new([chord_in_key], family: voicing_family, overrides: {0 => self}).voiced_chords.first
  end

  def self.resolve(name)
    find_by(name: name)
  end

  class << self
    alias_method :[], :resolve
  end

  def to_json(options = {})
    super({methods: [:notes]}.merge(options))
  end
end
