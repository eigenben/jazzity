module ApplicationHelper
  def navigation_link_to(name, path, controllers = [], actions = nil)
    controllers = [controllers] unless controllers.is_a?(Array)
    actions = [actions] if actions && !actions.is_a?(Array)
    
    current = controllers.any? {|c| controller.is_a?(c) } && (actions.nil? or actions.include?(controller.action_name.to_sym))
    content_tag(:li, link_to(name, path), :class => ("current" if current))
  end

  def link_to_search_example(name)
    link_to name, search_path(name)
  end

  def voice_leading_options_for_select(chord, position)
    options_for_select([[(position == 0 ? "Random Voicing" : "<= Voice Lead"), ">", ">= Voice Lead", "<"]], params[:v][position.to_s]) + options_from_collection_for_select(chord.voicings, :id, :name, params[:v][position.to_s])
  end
end
