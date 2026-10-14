class SearchesController < ApplicationController
  respond_to :html, :json

  def create
    if params[:query].present?
      redirect_to search_path(params[:query].strip)
    else
      redirect_to root_path
    end
  end

  def show
    @query = params[:id]

    @search = Search.new(@query)
    @results = @search.all

    respond_with @results do |format|
      format.html do
        if @results.size == 0
          redirect_to root_path, alert: "Nothing matched “#{@query}”. Try a chord symbol like Cmaj7, a scale like D Dorian, or notes like C E G."
        elsif @results.size == 1
          redirect_to path_to_searchable(@results.first)
        end
      end
    end
  end

  def autocomplete
    render json: Search.new(params[:q].to_s).suggestions
  end
end
