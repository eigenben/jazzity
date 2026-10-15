class ChordNoteSequencesController < ApplicationController
  include KeyScoped

  rate_limit_typed_input
  noindex
  before_action :find_chord_note_sequence

  respond_to :html

  def show
  end

  def staff
    respond_with @chord_note_sequence do |format|
      format.html { render layout: "staff" }
    end
  end

  protected

  def find_chord_note_sequence
    @chord_note_sequence = ChordNoteSequence[params[:id]] or raise ActiveRecord::RecordNotFound
    @chord_note_sequence = @chord_note_sequence.in_key_of(@key) if @key
  end
end
