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

    config.generators do |g|
      g.test_framework :rspec, fixture: false, views: false
      g.fixture_replacement :factory_bot, dir: "spec/factories"
      g.helper false
    end
  end
end
