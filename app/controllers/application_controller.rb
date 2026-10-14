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

  # The voicing family a progression is voiced in, from its slug in the
  # `family` parameter, defaulting to rootless voicings.
  def voicing_family
    @voicing_family ||= VoicingFamily.find_by(slug: params[:family].to_s) || VoiceLeader.default_family
  end

  # The voicing picked for each chord position, e.g. {"0" => "878", "1" => ""}.
  # Anything other than a flat hash of positions is ignored.
  def voicing_choices
    choices = params[:v]
    choices.respond_to?(:permit) ? choices.permit(*choices.keys).to_h : {}
  end

  helper_method :path_to_searchable
  helper_method :path_to_model
  helper_method :voicing_family
  helper_method :voicing_choices
end
