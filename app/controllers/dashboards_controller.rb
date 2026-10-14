class DashboardsController < ApplicationController
  def show
    @featured = ChordSequence["Dm7 G7 Cmaj7"]
    @reference = SearchEntry.all.reject { |entry| entry.kind == :progression }.sample(6).map do |entry|
      Search::Result.new(entry.target(Key.standard.sample), entry, 0)
    end
  end
end
