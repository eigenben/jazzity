class ChordNoteSequencesController < ApplicationController
  before_action :find_key
  before_action :find_chord_note_sequence, except: [:index]

  respond_to :html

  def index
  end

  def show
  end

  def staff
    respond_with @chord_note_sequence do |format|
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

  def find_chord_note_sequence
    @chord_note_sequence = ChordNoteSequence[params[:id]]
    @chord_note_sequence = @chord_note_sequence.in_key_of(@key) if @key
  end
end
