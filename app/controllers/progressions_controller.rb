class ProgressionsController < ApplicationController
  before_action :find_key
  before_action :find_progression, except: [:index, :new, :create]

  respond_to :html, :json

  def index
    @progression_families = ProgressionFamily.all

    respond_with @progression_families do |format|
      format.json { render json: @progression_families.to_json(include: [:progressions]) }
    end
  end

  def show
    params[:v] ||= {}
    respond_with @progression
  end

  def staff
    respond_with @progression do |format|
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

  def find_progression
    @progression = Progression.find_by(slug: params[:id])
    @progression = @progression.in_key_of(@key) if @key
    @staff_notes = @progression.staff_notes(params[:v] || {})
  end
end
