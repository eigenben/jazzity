class ChordsController < ApplicationController
  before_action :find_key
  before_action :find_chord, except: [:index, :new, :create]
  before_action :find_chord_qualities

  respond_to :html, :json

  def index
    respond_with @chord_qualities do |format|
      format.json { render json: @chord_qualities.to_json(include: [:chords]) }
    end
  end

  def show
    respond_with @chord
  end

  def staff
    respond_with @chord do |format|
      format.html { render layout: "staff" }
    end
  end


  protected

  def find_key
    if params[:key_id]
      @key = Key[params[:key_id]]
      @key = nil if @key.main?
    end
  end

  def find_chord
    @chord = Chord.find_by(slug: params[:id])
    @chord = @chord.in_key_of(@key) if @key
  end

  def find_chord_qualities
    @chord_qualities = ChordQuality.includes(:chords)
  end
end
