# Analyzes chord changes typed into a form: /analysis?changes=Dm7 G7 Cmaj7 A7
# goes to the changes' own chord sequence page, which carries the analysis.
# Without changes, or with changes it can't read, it shows the form.
class AnalysesController < ApplicationController
  rate_limit_typed_input

  def show
    @changes = params[:changes].is_a?(String) ? params[:changes].squish : ""

    if (sequence = ChordSequence[@changes])
      redirect_to polymorphic_path(sequence, anchor: "analysis")
    elsif @changes.present?
      typed = ChordSequence.new(@changes)
      @unreadable = typed.invalid_chords
      @too_many = typed.chords.size > ChordSequence::MAX_CHORDS
      render :show, status: :unprocessable_content
    end
  end
end
