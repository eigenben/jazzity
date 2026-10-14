# Analyzes chord changes typed into a form: /analysis?changes=Dm7 G7 Cmaj7 A7
# goes to the changes' own chord sequence page, which carries the analysis.
# Without changes, or with changes it can't read, it shows the form.
class AnalysesController < ApplicationController
  def show
    @changes = params[:changes].is_a?(String) ? params[:changes].squish : ""

    if (sequence = ChordSequence[@changes])
      redirect_to polymorphic_path(sequence, anchor: "analysis")
    elsif @changes.present?
      @unreadable = ChordSequence.new(@changes).invalid_chords
      render :show, status: :unprocessable_content
    end
  end
end
