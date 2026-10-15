class DashboardsController < ApplicationController
  def show
    @featured = ChordSequence["Dm7 G7 Cmaj7"]
    @reference = SearchEntry.all.reject { |entry| entry.kind == :progression }.sample(9).map do |entry|
      Search::Result.new(entry.target(readable_key_for(entry)), entry, 0)
    end
  end

  protected

  # A key to show an entry in that spells it without double sharps or
  # flats, so the home page never opens on Dbø7 as Db Fb Abb Cb.
  def readable_key_for(entry)
    Key.standard.select { |key| entry.target(key).readable? }.sample
  end
end
