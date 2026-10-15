require "spec_helper"

RSpec.describe "Rate limits", type: :request do
  # The test cache stores nothing, so each count comes back past the limit.
  before { allow(Rails.cache).to receive(:increment).and_return(1_000) }

  ["/searches/dorian", "/searches/autocomplete?q=dor", "/analysis?changes=Dm7+G7", "/chord-sequences/Dm7,G7",
   "/keys/Eb/chord-sequences/Dm7,G7", "/notes/C%20E%20G", "/chord-notes/C%20E%20G,F%20A%20C"].each do |path|
    it "turns away too many requests for #{path}" do
      get path
      expect(response).to have_http_status(:too_many_requests)
      expect(response.body).to include("Too many requests")
    end
  end

  it "turns requests away before reading what was typed" do
    expect(ChordSequence).not_to receive(:resolve)
    get "/chord-sequences/Dm7,G7"
  end

  it "counts each visitor's requests for a minute" do
    get "/chord-sequences/Dm7,G7", headers: {"REMOTE_ADDR" => "203.0.113.7"}
    expect(Rails.cache).to have_received(:increment).with("rate-limit:chord_sequences:203.0.113.7", 1, expires_in: 1.minute)
  end

  it "doesn't limit pages looked up by name" do
    get "/chords/major-7"
    expect(response).to have_http_status(:ok)
  end
end
