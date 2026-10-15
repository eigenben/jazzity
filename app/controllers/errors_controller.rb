# Renders the page for a 404 inside the site, with the search box and
# things to try, so a mistyped or stale link isn't a dead end. Other
# errors get the static pages in public/, which don't need the app.
class ErrorsController < ApplicationController
  skip_forgery_protection

  def not_found
    respond_to do |format|
      format.html { render status: :not_found }
      format.any { head :not_found }
    end
  end
end
