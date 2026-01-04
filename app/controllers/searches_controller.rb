class SearchesController < ApplicationController
  respond_to :html, :json

  def create
    redirect_to action: :show, id: params[:query]
  end

  def show
    params[:query] = params[:id]

    @search = Search.new(CGI.unescape(params[:id]))
    @results = @search.all

    respond_with @results do |format|
      format.html do
        if @results.size == 0
          redirect_to root_path, alert: 'Sorry, but no results were found.'
        elsif @results.size == 1
          redirect_to path_to_searchable(@results.first)
        end
      end
    end
  end

  def autocomplete
    params[:id] = params[:q]
    show
  end
end
