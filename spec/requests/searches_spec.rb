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

  {
    "Cmaj7" => "/chords/major-7", "C#maj7" => "/keys/C%23/chords/major-7", "Dbmaj7" => "/keys/Db/chords/major-7",
    "C maj7" => "/chords/major-7", "Cm7b5" => "/chords/half-diminished", "Cø7" => "/chords/half-diminished",
    "C-7" => "/chords/minor-7", "Cmin7" => "/chords/minor-7", "Cdim7" => "/chords/diminished-7", "Co7" => "/chords/diminished-7",
    "C7b5" => "/chords/dominant-b5", "Bbm7" => "/keys/Bb/chords/minor-7", "BbM7" => "/keys/Bb/chords/major-7",
    "C13" => "/chords/dominant-13", "Cmaj9" => "/chords/major-9", "CΔ7" => "/chords/major-7", "C^7" => "/chords/major-7",
    "C7sus4" => "/chords/dominant-7-sus4", "Csus" => "/chords/suspended-4", "C9" => "/chords/dominant-9", "Cm9" => "/chords/minor-9",
    "C7(b9)" => "/chords/dominant-b9", "C7/E" => "/chords/dominant-7", "C" => "/chords/major-triad", "Eb" => "/keys/Eb/chords/major-triad",
    "D dorian" => "/scales/major/modes/dorian", "dorian D" => "/scales/major/modes/dorian", "lydian" => "/scales/major/modes/lydian",
    "f# melodic minor" => "/keys/F%23/scales/melodic-minor", "C major" => "/scales/major",
    "ii-V-I" => "/progressions/major-ii-v-i", "ii V I" => "/progressions/major-ii-v-i", "ii V I in Eb" => "/keys/Eb/progressions/major-ii-v-i",
    "251" => "/progressions/major-ii-v-i", "rhythm changes" => "/progressions/rhythm-changes",
    "C E G" => "/notes/C%20E%20G", "C E G B" => "/notes/C%20E%20G%20B",
    "Dm7 G7 Cmaj7" => "/chord-sequences/Dm7,G7,Cmaj7", "Dm7 G7 C" => "/chord-sequences/Dm7,G7,C",
    "Dm7 | G7 | Cmaj7" => "/chord-sequences/Dm7,G7,Cmaj7", "Em7 A7 Dm7 G7" => "/chord-sequences/Em7,A7,Dm7,G7",
    "analyze Dm7 G7 Cmaj7 A7" => "/chord-sequences/Dm7,G7,Cmaj7,A7", "analyse ii V I in Eb" => "/chord-sequences/Fm7,Bb7,Ebmaj7",
    "backdoor" => "/progressions/backdoor-ii-v-i", "coltrane changes" => "/progressions/coltrane-changes", "bird blues in F" => "/keys/F/progressions/bird-blues",
    "iv7 bVII7 Imaj7" => "/progressions/backdoor-ii-v-i", "ii bII I" => "/progressions/tritone-sub-ii-v-i",
    "C alt" => "/chords/altered", "Galt" => "/keys/G/chords/altered",
    "Ab Lydian Augmented" => "/keys/F/scales/melodic-minor/modes/lydian-augmented", "whole tone" => "/scales/whole-tone",
    "dorain" => "/scales/major/modes/dorian", "mixolidian" => "/scales/major/modes/mixolydian"
  }.each do |query, path|
    it "goes straight from #{query} to #{path}" do
      get search_path(query)
      expect(response).to redirect_to(path)
      follow_redirect!
      expect(response).to have_http_status(:ok)
    end
  end

  it "lists matches by kind when a name matches several things" do
    get search_path("blues")
    expect(response).to have_http_status(:ok)
    page = Nokogiri::HTML(response.body)
    expect(page.css(".section-heading").map { |heading| heading.text.squish }).to eq(["Scales & modes 2", "Progressions 6"])
  end

  %w[minor altered bebop].each do |query|
    it "lists the chords, scales and progressions #{query} matches" do
      get search_path(query)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("matches")
    end
  end

  it "shows a page for nothing found with what to try" do
    get search_path("xyzzy")
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Nothing matched “xyzzy”", "Things to try", "ii V I in Eb")
  end

  it "logs each query that finds nothing" do
    allow(Rails.logger).to receive(:info)

    get search_path("autumn leaves")
    get search_path("Cmaj7")

    expect(Rails.logger).to have_received(:info).with('Search found nothing: "autumn leaves"').once
    expect(Rails.logger).not_to have_received(:info).with(/Search found nothing: "Cmaj7"/)
  end

  it "suggests close names when nothing matches outright" do
    get search_path("dorien bebip")
    expect(response.body).to include("Did you mean")
  end

  it "says when a query was corrected" do
    get search_path("dorain")
    expect(flash[:notice]).to eq("Showing results for “dorian”.")
  end

  it "suggests labelled names with their pages as JSON while typing" do
    get autocomplete_searches_path(format: :json), params: {q: "dor"}
    expect(response.parsed_body).to include({"label" => "D Dorian", "detail" => "scale", "url" => "/scales/major/modes/dorian"})
    expect(response.parsed_body.size).to be <= 8
  end

  it "finds nothing for a query too long to read" do
    get search_path((["dorian"] * 100).join(" "))
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Nothing matched")

    get autocomplete_searches_path(format: :json), params: {q: (["dorian"] * 100).join(" ")}
    expect(response.parsed_body).to eq([])
  end
end

RSpec.describe "Missing pages", type: :request do
  it "responds with 404 for unknown records and keys" do
    get "/chords/not-a-chord"
    expect(response).to have_http_status(:not_found)

    get "/keys/H/chords/major-7"
    expect(response).to have_http_status(:not_found)
  end

  it "responds with 404 for sequences too long to show" do
    get "/chord-sequences/#{(%w[Dm7 G7] * ChordSequence::MAX_CHORDS).join(",")}"
    expect(response).to have_http_status(:not_found)

    get "/notes/#{(["C"] * (NoteSequence::MAX_NOTES + 1)).join("%20")}"
    expect(response).to have_http_status(:not_found)

    get "/chord-notes/#{(["C%20E%20G"] * (ChordNoteSequence::MAX_GROUPS + 1)).join(",")}"
    expect(response).to have_http_status(:not_found)
  end
end
