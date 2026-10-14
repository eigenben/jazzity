class DashboardsController < ApplicationController
  def show
    @featured = ChordSequence["Dm7 G7 Cmaj7"]
    @searchables = Searchable.where.not(:model_type => "Progression").reorder("RANDOM()").limit(6)
  end
end
