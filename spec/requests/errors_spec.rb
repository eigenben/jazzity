require "spec_helper"

RSpec.describe "Error pages", type: :request do
  # Show the pages visitors see, not the details shown in development.
  around do |example|
    env_config = Rails.application.env_config
    saved = env_config.slice("action_dispatch.show_detailed_exceptions", "action_dispatch.show_exceptions")
    env_config.merge!("action_dispatch.show_detailed_exceptions" => false, "action_dispatch.show_exceptions" => :all)
    example.run
  ensure
    env_config.merge!(saved)
  end

  def page_html
    Nokogiri::HTML(response.body)
  end

  def heading
    page_html.at_css("h1").text.strip
  end

  it "shows a page that isn't there inside the site, with things to try" do
    get "/chords/no-such-chord"

    expect(response).to have_http_status(:not_found)
    expect(heading).to eq("That page isn't in the book")
    expect(response.body).to include("Things to try")
    expect(page_html.at_css("form.search")).to be_present
  end

  it "shows the same page for a path the site doesn't route" do
    get "/no/such/page"

    expect(response).to have_http_status(:not_found)
    expect(heading).to eq("That page isn't in the book")
  end

  it "answers a 404 for something other than a page with no body" do
    get "/chords/no-such-chord.json"

    expect(response).to have_http_status(:not_found)
    expect(response.body).to be_empty
  end

  it "shows the static page for any other error" do
    allow(Search).to receive(:new).and_raise("Broken")

    get "/searches/Ebmaj7"

    expect(response).to have_http_status(:internal_server_error)
    expect(heading).to eq("Something went wrong")
  end
end
