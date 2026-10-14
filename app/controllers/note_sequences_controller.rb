class NoteSequencesController < ApplicationController
  include KeyScoped

  before_action :find_note_sequence

  respond_to :html

  def show
  end

  def staff
    respond_with @note_sequence do |format|
      format.html { render layout: "staff" }
    end
  end

  protected

  def find_note_sequence
    @note_sequence = NoteSequence[params[:id]] or raise ActiveRecord::RecordNotFound
    @note_sequence = @note_sequence.in_key_of(@key) if @key
  end
end
