# Resources nested under /keys/:key_id are shown transposed into that key.
# C is the reference key, so /keys/C/... behaves the same as no key at all.
# Any key written with at most one sharp or flat works, including C# and F#.
module KeyScoped
  extend ActiveSupport::Concern

  included do
    before_action :find_key
  end

  protected

  def find_key
    return unless params[:key_id]

    @key = Key.from_name(params[:key_id])
    raise ActiveRecord::RecordNotFound if @key.nil? || @key.double?

    @key = nil if @key.main?
  end
end
