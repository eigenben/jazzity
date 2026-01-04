class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  protected

  def path_to_searchable(searchable)
    path_to_model(searchable.target)
  end

  def path_to_model(model)
    if model.is_a?(Mode)
      [(model.respond_to?(:key) ? model.key : nil), model.scale, model].compact
    elsif model.is_a?(Voicing)
      [(model.respond_to?(:key) ? model.key : nil), model.chord, model].compact
    else
      [(model.respond_to?(:key) ? model.key : nil), model].compact
    end
  end

  # Applies Textile and StaffNotation parsers to produce HTML
  def text_to_html(text)
    RedCloth.new(StaffNotation.parse(text.to_s)).to_html
  end

  helper_method :path_to_searchable
  helper_method :path_to_model
  helper_method :text_to_html
  
end
