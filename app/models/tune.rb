class Tune < ActiveRecord::Base
  extend FriendlyId
  include Searchable::Model
  
  has_many :searchables, as: :model
  belongs_to :meter
  belongs_to :form
  belongs_to :starting_chord, class_name: "Chord"
  belongs_to :ending_chord, class_name: "Chord"
  belongs_to :contrafact_of_tune, class_name: "Tune"
  belongs_to :based_on_progression, class_name: "Progression"
  has_many :tune_progressions, dependent: :destroy
  has_many :progressions, through: :tune_progressions

  friendly_id :name, use: :slugged

  scope :with_style, ->(s) { where(style: s) }
  scope :with_form, ->(f) { where(form_id: f.id) }
  scope :with_meter, ->(m) { where(meter_id: m.id) }
  scope :with_based_on_progression, ->(p) { where(based_on_progression_id: p.id) }
  scope :search, ->(q) { where("CONCAT(name, ' ', composer) LIKE ?", "%#{q}%") }
  scope :featured, -> { where(featured: true) }

  validates :name, presence: true
  validates :tonality, inclusion: { in: ["Major", "Minor"] }

  define_searchables do
    searchables.destroy_all
    searchables.create(name: title_with_composer, display_name: title)
  end

  def self.unique_styles
    Tune.where("style IS NOT NULL").pluck("DISTINCT style")
  end

  def title
    alternate_name.present? ? "#{name} (#{alternate_name})" : name
  end

  def title_with_composer
    if composer?
      "#{title} by #{composer}"
    else
      title
    end
  end

  def to_s
    title
  end

  def primary_key
    Key[primary_key_name]
  end
  def secondary_key
    Key[secondary_key_name]
  end

  def chord_changes
    @changes ||= Changes.new(JSON.parse(changes_json)) if changes_json
  end

  def self.resolve(name)
    find_by(name: name)
  end

  class << self
    alias_method :[], :resolve
  end
end
