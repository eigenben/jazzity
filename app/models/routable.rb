# Lets plain Ruby domain objects (keys and the various note/chord sequences)
# be handed to link_to, url_for and respond_with just like Active Record models.
module Routable
  extend ActiveSupport::Concern

  included do
    extend ActiveModel::Naming
    include ActiveModel::Conversion
  end

  def persisted?
    true
  end
end
