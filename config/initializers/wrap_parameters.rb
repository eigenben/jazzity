# Be sure to restart your server when you modify this file.
#
# This file contains the settings for ActionController::ParametersWrapper
# which will be enabled by default in the upcoming version of Ruby on Rails.

# Enable parameter wrapping for JSON. You can disable this by set :format to empty array.
ActiveSupport.on_load(:action_controller) do
  wrap_parameters format: [:json]
end
