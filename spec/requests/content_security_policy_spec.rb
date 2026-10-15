require "spec_helper"

RSpec.describe "Content security policy", type: :request do
  def policy
    response.headers["Content-Security-Policy"].split(/;\s*/).to_h { |directive| directive.split(" ", 2) }
  end

  it "allows scripts only from the app and with the page's nonce" do
    get root_path
    nonce = Nokogiri::HTML(response.body).at("meta[name=csp-nonce]")["content"]

    expect(nonce).to be_present
    expect(policy["script-src"]).to eq("'self' 'nonce-#{nonce}'")
    expect(Nokogiri::HTML(response.body).css("script").map { |script| script["nonce"] }).to all(eq(nonce))
  end

  it "keeps the nonce for the rest of the visit, for Turbo" do
    get root_path
    first = policy["script-src"]
    get chords_path
    expect(policy["script-src"]).to eq(first)
  end

  it "allows Google Fonts and VexFlow's embedded fonts, and no framing" do
    get root_path
    expect(policy).to include("default-src" => "'self'", "object-src" => "'none'", "frame-ancestors" => "'none'",
                              "font-src" => "'self' data: https://fonts.gstatic.com")
    expect(policy["style-src"]).to include("https://fonts.googleapis.com")
  end
end
