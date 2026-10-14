# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

# One transaction, so SQLite writes the reference data in a single commit.
ActiveRecord::Base.transaction do
  ### CLEAR EXISTING JAZZ MODEL TABLE ###
  %w[
    meters
    forms
    progression_families
    progressions
    progression_components
    chord_qualities
    chord_scales
    chord_symbols
    chords
    modes
    scales
    voicing_families
    voicings
    voice_leadings
    searchables
  ].each do |table|
    ActiveRecord::Base.connection.execute "DELETE FROM #{table}"
  end

  %w[
    meters
    forms
    scales
    chords
    voicings
    progressions
  ].each { |f| require Rails.root.join("db/seeds/#{f}.rb") }

  Searchable.regenerate_all
end
