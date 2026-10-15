# Lists every page of the reference in every key for search engines, and
# points them to the list from robots.txt.
class SitemapsController < ApplicationController
  def show
    @chords = Chord.includes(:voicings).order(:id)
    @scales = Scale.includes(:modes).order(:id)
    @progressions = Progression.order(:id)
  end

  def robots
  end
end
