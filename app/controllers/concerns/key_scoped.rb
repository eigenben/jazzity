# Resources nested under /keys/:key_id are shown transposed into that key.
# C is the reference key, so /keys/C/... behaves the same as no key at all.
module KeyScoped
  extend ActiveSupport::Concern

  included do
    before_action :find_key
  end

  protected

  def find_key
    return unless params[:key_id]

    @key = Key[params[:key_id]] or raise ActiveRecord::RecordNotFound
    @key = nil if @key.main?
  end
end
