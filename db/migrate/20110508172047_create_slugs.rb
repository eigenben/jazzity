class CreateSlugs < ActiveRecord::Migration
  TABLES = [
    :chord_qualities, :chords, :forms, :meters, :modes,
    :progression_families, :progressions, :scales, :tunes, :vehicles, :voicings, :voicing_families
  ]

  def change
    TABLES.each do |table|
      add_column table, :slug, :string
      add_index table, :slug
    end
  end
end
