require "spec_helper"

RSpec.describe "Keys in paths", type: :request do
  it "redirects a key typed in lower case to its proper spelling" do
    get "/keys/eb/chords/major-7"

    expect(response).to redirect_to("/keys/Eb/chords/major-7")
    expect(response).to have_http_status(:moved_permanently)
  end

  it "keeps the query string when it redirects" do
    get "/keys/f%23/progressions/major-ii-v-i/practice?order=chromatic"

    expect(response).to redirect_to("/keys/F%23/progressions/major-ii-v-i/practice?order=chromatic")
  end

  it "doesn't know keys with double sharps or flats, or that aren't keys" do
    get "/keys/Ebb/chords"
    expect(response).to have_http_status(:not_found)

    get "/keys/x/chords"
    expect(response).to have_http_status(:not_found)
  end
end
