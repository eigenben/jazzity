class ChordSequencesController < ApplicationController
  include KeyScoped

  before_action :find_chord_sequence

  respond_to :html

  def show
  end

  def staff
    respond_with @chord_sequence do |format|
      format.html { render layout: "staff" }
    end
  end

  protected

  def find_chord_sequence
    @chord_sequence = ChordSequence[params[:id]] or raise ActiveRecord::RecordNotFound
    @chord_sequence = @chord_sequence.in_key_of(@key) if @key
    @staff_notes = @chord_sequence.staff_notes(voicing_choices)
  end
end
