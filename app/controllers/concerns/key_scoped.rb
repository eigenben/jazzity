# Resources nested under /keys/:key_id are shown transposed into that key.
# C is the reference key, so /keys/C/... behaves the same as no key at all.
# Any key written with at most one sharp or flat works, including C# and F#.
# A key typed in another case, as in /keys/eb/..., redirects to its proper
# spelling.
module KeyScoped
  extend ActiveSupport::Concern

  included do
    before_action :find_key
  end

  protected

  def find_key
    return unless params[:key_id]

    @key = Key.parse(params[:key_id])
    raise ActiveRecord::RecordNotFound if @key.nil? || @key.double?
    return redirect_to(_path_in_key(@key), status: :moved_permanently) if @key.name != params[:key_id]

    @key = nil if @key.main?
  end

  def _path_in_key(key)
    path = url_for(request.path_parameters.merge(:key_id => key.name, :only_path => true))
    request.query_string.present? ? "#{path}?#{request.query_string}" : path
  end
end
