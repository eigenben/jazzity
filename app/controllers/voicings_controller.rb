class VoicingsController < ApplicationController
  before_action :set_body_class
  before_action :find_key
  before_action :find_chord
  before_action :find_chord_qualities
  before_action :find_voicing, except: [:index, :new, :create]

  respond_to :html, :json

  def index
    @voicings = @chord.voicings
    respond_with @voicings
  end

  def show
    respond_with @voicing
  end


  protected

  def set_body_class
    @body_class = "chords"
  end

  def find_key
    if params[:key_id]
      @key = Key[params[:key_id]]
      @key = nil if @key.main?
    end
  end

  def find_chord_qualities
    @chord_qualities = ChordQuality.includes(:chords)
  end

  def find_chord
    @chord = Chord.find_by(slug: params[:chord_id])
    @chord = @chord.in_key_of(@key) if @key
  end

  def find_voicing
    @voicing = @chord.voicings.find(params[:id])
    @voicing = @voicing.in_key_of(@key) if @key
  end
end
