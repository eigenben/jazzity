class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  protected

  def path_to_searchable(searchable)
    path_to_model(searchable.target)
  end

  def path_to_model(model)
    parents = case model
    when Mode then [model.scale]
    when Voicing then [model.chord]
    else []
    end

    helpers.in_key(model.key, *parents, model)
  end

  helper_method :path_to_searchable
  helper_method :path_to_model
end
