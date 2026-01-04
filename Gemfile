source "https://rubygems.org"

# Core Gems
ruby "3.4.4"

gem "rails", "~> 8.0.0"
gem "sqlite3"
gem "responders"
gem "puma"
gem "bootsnap", require: false
gem "propshaft"

# Assets / Frontend
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"

# Views

# Bread & Butter Gems
gem "acts_as_list"
gem "acts_as_tree"
gem "simple_form"
gem "friendly_id"
gem "awesome_nested_set"
gem "kaminari", "~> 1.2"
gem "mini_magick"
gem "RedCloth"

group :development do
  gem "capistrano", "~> 3.17"
end

group :test do
  gem "turn", require: false
  gem "minitest"
  gem "faker"
  gem "rspec-rails"
  gem "database_cleaner"
  gem "launchy"
  gem "pickle"
  gem "shoulda-matchers"
  gem "growl"
  gem "capybara"
end

group :development, :test do
  gem "factory_bot_rails"
end
