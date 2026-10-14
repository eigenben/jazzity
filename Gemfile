source "https://rubygems.org"

ruby file: ".ruby-version"

gem "rails", "~> 8.1.0"
gem "sqlite3"
gem "puma"
gem "bootsnap", require: false

# Assets / Frontend
gem "propshaft"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"

# Domain
gem "responders"
gem "friendly_id"
gem "acts_as_tree"
gem "RedCloth"

group :development, :test do
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "brakeman", require: false
  gem "bundler-audit", require: false
  gem "rubocop-rails-omakase", require: false
end

group :test do
  gem "capybara"
  gem "shoulda-matchers"
end
