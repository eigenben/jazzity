class NoteSequencesController < ApplicationController
  before_action :find_key
  before_action :find_note_sequence, except: [:index]

  respond_to :html

  def index
  end

  def show
  end

  def staff
    respond_with @note_sequence do |format|
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

  def find_note_sequence
    @note_sequence = NoteSequence[params[:id]]
    @note_sequence = @note_sequence.in_key_of(@key) if @key
  end
end
