class ProgressionsController < ApplicationController
  include KeyScoped

  before_action :find_progression, except: :index
  before_action :voice_progression, only: %i[show staff]

  respond_to :html, :json

  def index
    @progression_families = ProgressionFamily.includes(:progressions => {:components => :chord}).order(:id)

    respond_with @progression_families do |format|
      format.json { render json: @progression_families.to_json(include: [:progressions]) }
    end
  end

  def show
    respond_with @progression
  end

  def staff
    respond_with @progression do |format|
      format.html { render layout: "staff" }
    end
  end

  # A sheet to print, with the progression voiced in all twelve keys.
  def practice
    @order = Key::PRACTICE_ORDERS.key?(params[:order]) ? params[:order] : "fourths"
    @progressions = @progression.in_every_key(@order)
  end

  protected

  def find_progression
    @progression = Progression.find_by!(slug: params[:id])
    @progression = @progression.in_key_of(@key) if @key
  end

  def voice_progression
    @voiced_chords = @progression.voiced_chords(family: voicing_family, overrides: voicing_choices)
  end
end
