require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"

Bundler.require(*Rails.groups)

module Jazzity
  class Application < Rails::Application
    config.load_defaults 8.1

    # Several associations (parent chords, upper structure chords, voicing
    # families) are legitimately empty, so they are optional unless stated.
    config.active_record.belongs_to_required_by_default = false

    config.autoload_lib(ignore: %w[assets tasks])

    # Page views are counted by our own Umami. The tracking script is only
    # added where a website id is set, which is production.
    config.x.umami_url = "https://metrics.jazzity.com"
    config.x.umami_website_id = nil

    # A 404 is rendered by the app, with search; anything else gets the
    # static page in public/, since the app may be what's broken.
    config.exceptions_app = lambda do |env|
      if env["PATH_INFO"] == "/404"
        ErrorsController.action(:not_found).call(env)
      else
        ActionDispatch::PublicExceptions.new(Rails.public_path).call(env)
      end
    end

    config.generators do |g|
      g.test_framework :rspec, fixture: false, views: false
      g.fixture_replacement :factory_bot, dir: "spec/factories"
      g.helper false
    end
  end
end
