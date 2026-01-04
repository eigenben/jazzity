class ChordSequencesController < ApplicationController
  before_action :find_key
  before_action :find_chord_sequence, except: [:index]

  respond_to :html

  def index
  end

  def show
    params[:v] ||= {}
  end

  def staff
    respond_with @chord_sequence do |format|
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

  def find_chord_sequence
    @chord_sequence = ChordSequence[params[:id]]
    @chord_sequence = @chord_sequence.in_key_of(@key) if @key
    @staff_notes = @chord_sequence.staff_notes(params[:v] || {})
  end
end
