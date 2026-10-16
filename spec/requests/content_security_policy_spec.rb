require "spec_helper"

RSpec.describe "Content security policy", type: :request do
  def policy
    response.headers["Content-Security-Policy"].split(/;\s*/).to_h { |directive| directive.split(" ", 2) }
  end

  it "allows scripts only from the app and Umami, and with the page's nonce" do
    get root_path
    nonce = Nokogiri::HTML(response.body).at("meta[name=csp-nonce]")["content"]

    expect(nonce).to be_present
    expect(policy["script-src"]).to eq("'self' https://metrics.jazzity.com 'nonce-#{nonce}'")
    expect(policy["connect-src"]).to eq("'self' https://metrics.jazzity.com")
    expect(Nokogiri::HTML(response.body).css("script").map { |script| script["nonce"] }).to all(eq(nonce))
  end

  it "adds Umami's tracking script, with the nonce, only when a website id is set" do
    get root_path
    expect(Nokogiri::HTML(response.body).at("script[data-website-id]")).to be_nil

    allow(Rails.configuration.x).to receive(:umami_website_id).and_return("abc-123")
    get root_path
    page = Nokogiri::HTML(response.body)
    script = page.at("script[data-website-id]")

    expect(script["src"]).to eq("https://metrics.jazzity.com/script.js")
    expect(script["data-website-id"]).to eq("abc-123")
    expect(script["defer"]).to be_present
    expect(script["nonce"]).to eq(page.at("meta[name=csp-nonce]")["content"])
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
