require "spec_helper"

RSpec.describe "Search engines", type: :request do
  def canonical
    Nokogiri::HTML(response.body).at_css("link[rel=canonical]")["href"]
  end

  it "points robots.txt at the sitemap" do
    get "/robots.txt"

    expect(response.body).to include("Sitemap: http://www.example.com/sitemap.xml")
  end

  it "lists every page of the reference in every key" do
    get "/sitemap.xml"

    locations = Nokogiri::XML(response.body).remove_namespaces!.css("loc").map { |loc| URI(loc.text).path }
    expect(locations).to include("/", "/chords/major-7", "/keys/F%23/chords/major-7", "/keys/Eb/chords/major-7/voicings/type-i",
      "/keys/Bb/scales/major/modes/dorian", "/keys/Bb/progressions/rhythm-changes", "/progressions/rhythm-changes/practice")
    expect(locations).not_to include(a_string_starting_with("/keys/C/"))
    expect(locations).to eq(locations.uniq)

    locations.sample(20, random: Random.new(1)).each do |path|
      get path
      expect(response).to have_http_status(:ok), path
    end
  end

  it "files a page in C and the same page without its query under the URL without them" do
    get "/keys/C/chords/major-7"
    expect(canonical).to eq("http://www.example.com/chords/major-7")

    get "/keys/Bb/progressions/rhythm-changes?family=shells"
    expect(canonical).to eq("http://www.example.com/keys/Bb/progressions/rhythm-changes")
  end

  it "keeps searches, typed sequences and bare staves out of the index" do
    ["/searches/xyzzy", "/chord-sequences/Dm7,G7,Cmaj7", "/notes/C%20E%20G", "/chords/major-7/staff"].each do |path|
      get path
      expect(response.headers["X-Robots-Tag"]).to eq("noindex"), path
    end

    get "/chords/major-7"
    expect(response.headers["X-Robots-Tag"]).to be_nil
  end
end
