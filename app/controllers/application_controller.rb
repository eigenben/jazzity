class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # Pages made from what's typed into them (searches, analyses and
  # sequences) take far longer than pages looked up by name, so each
  # visitor gets only so many a minute.
  def self.rate_limit_typed_input(to: 60, **options)
    rate_limit to: to, within: 1.minute, **options, with: -> {
      render plain: "Too many requests. Please wait a minute and try again.", status: :too_many_requests
    }
  end

  protected

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
    @voicing_family ||= picked_voicing_family || VoiceLeader.default_family
  end

  # The slug of the family picked, when it names one.
  def voicing_family_slug
    picked_voicing_family&.slug
  end

  def picked_voicing_family
    return @picked_voicing_family if defined?(@picked_voicing_family)

    slug = params[:family] if params[:family].is_a?(String)
    @picked_voicing_family = (VoicingFamily.find_by(slug: slug) if slug.present?)
  end

  # The voicing picked for each chord position, e.g. {"0" => "878", "1" => ""}.
  # Only positions a sequence can have and voicing ids are kept, since
  # they're carried into every link to another key.
  def voicing_choices
    @voicing_choices ||= begin
      choices = params[:v]
      choices = choices.respond_to?(:permit) ? choices.permit(*choices.keys).to_h : {}
      choices.select { |position, voicing| position.match?(/\A\d+\z/) && position.to_i < ChordSequence::MAX_CHORDS && voicing.to_s.match?(/\A\d*\z/) }
    end
  end

  helper_method :path_to_model
  helper_method :voicing_family
  helper_method :voicing_family_slug
  helper_method :voicing_choices
end
