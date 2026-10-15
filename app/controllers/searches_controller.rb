class SearchesController < ApplicationController
  rate_limit_typed_input to: 120

  respond_to :html, :json

  def create
    if params[:query].present?
      redirect_to search_path(params[:query].strip)
    else
      redirect_to root_path
    end
  end

  # Goes straight to what the query names, or lists what it matches by
  # name, or says nothing matched and suggests what to try.
  def show
    @query = params[:id]
    @search = Search.new(@query)

    respond_to do |format|
      format.html do
        if (destination = @search.destination)
          flash[:notice] = @search.note if @search.note
          redirect_to path_to_model(destination)
        elsif @search.strong_results.empty?
          log_nothing_found
          render :empty
        end
      end
      format.json { render json: describe(@search.strong_results) }
    end
  end

  def autocomplete
    render json: describe(Search.new(params[:q].to_s).suggestions)
  end

  protected

  # What people look for and don't find is what the reference should
  # cover next, so each such query is logged on a line of its own.
  def log_nothing_found
    logger.info("Search found nothing: #{@query.truncate(200).inspect}")
  end

  def describe(results)
    results.map do |result|
      {:label => result.label, :detail => result.detail, :url => polymorphic_path(path_to_model(result.target))}
    end
  end
end
