class DashboardsController < ApplicationController
  def show
    @searchables = Searchable.limit(5).order("RANDOM()")
  end
end
