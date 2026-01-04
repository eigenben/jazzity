class TunesController < ApplicationController
  before_action :find_tune, except: [:index, :search, :new, :create]
  before_action :find_filters, :only => [:index]

  respond_to :html, :json

  def index
    @tunes = Tune.all.page(params[:page]).per(100)
    @tunes = @tunes.with_style(@style) if @style
    @tunes = @tunes.with_form(@form) if @form
    @tunes = @tunes.with_meter(@meter) if @meter
    @tunes = @tunes.with_based_on_progression(@progression) if @progression
    @tunes = @tunes.search(params[:query]) if params[:query].present?

    flash.now[:warning] = "We're still seeding content for this section. <a href='/contribute'>Want to contribute</a>?"

    respond_with @tunes
  end

  def show
    flash.now[:warning] = "We're still seeding content for this page. <a href='/contribute'>Want to contribute</a>?"
    respond_with @tune
  end


  protected

  def find_tune
    @tune = Tune.find(params[:id])
  end

  def find_filters
    @style = params[:style] if params[:style].present?
    @form = Form.find(params[:form]) if params[:form].present?
    @meter = Meter.find(params[:meter]) if params[:meter].present?
    @progression = Progression.find(params[:progression]) if params[:progression].present?
  end
end
