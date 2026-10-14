require "spec_helper"

RSpec.describe "Searching", type: :request do
  it "redirects a submitted query to its results" do
    post searches_path, params: {query: " Ebmaj7 "}
    expect(response).to redirect_to(search_path("Ebmaj7"))
  end

  it "sends a blank query back home" do
    post searches_path, params: {query: ""}
    expect(response).to redirect_to(root_path)
  end

  it "goes straight to the page when there is a single match" do
    get search_path("Dm7 G7 Cmaj7")
    expect(response).to redirect_to("/chord-sequences/Dm7,G7,Cmaj7")
  end

  it "lists results when there are several matches" do
    get search_path("Dorian")
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Eb Dorian")
  end

  it "explains what to try when nothing matches" do
    get search_path("qwertyuiop")
    expect(response).to redirect_to(root_path)
    expect(flash[:alert]).to include("Try a chord symbol")
  end

  it "suggests names as JSON while typing" do
    get autocomplete_searches_path(format: :json), params: {q: "dor"}
    expect(response.parsed_body).to include("D Dorian Scale")
    expect(response.parsed_body.size).to be <= 8
  end
end

RSpec.describe "Missing pages", type: :request do
  it "responds with 404 for unknown records and keys" do
    get "/chords/not-a-chord"
    expect(response).to have_http_status(:not_found)

    get "/keys/H/chords/major-7"
    expect(response).to have_http_status(:not_found)
  end
end
