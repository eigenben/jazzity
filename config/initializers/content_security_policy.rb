# Pages load scripts only from the app, with a nonce for the importmap's
# inline scripts, and fonts from Google Fonts (VexFlow's music fonts are
# data: URIs). Styles allow inline attributes, which the piano keyboard
# and VexFlow's SVG use. See https://guides.rubyonrails.org/security.html#content-security-policy-header
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.base_uri :self
    policy.connect_src :self
    policy.font_src :self, :data, "https://fonts.gstatic.com"
    policy.form_action :self
    policy.frame_ancestors :none
    policy.img_src :self, :data
    policy.object_src :none
    policy.script_src :self
    policy.style_src :self, :unsafe_inline, "https://fonts.googleapis.com"
  end

  # The nonce stays the same across a visit, so scripts in pages Turbo
  # fetches match the policy of the page they're merged into. It's kept in
  # the session rather than taken from the session id, which a first visit
  # doesn't have yet.
  config.content_security_policy_nonce_generator = ->(request) { request.session[:csp_nonce] ||= SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src]
end
