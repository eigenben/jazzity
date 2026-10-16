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
    expect(locations).to include("/", "/chords/major-7", "/keys/F%23/chords/major-7", "/keys/Eb/chords/major-7/voicings/type-a",
      "/keys/Bb/scales/major/modes/dorian", "/keys/Bb/progressions/rhythm-changes", "/progressions/rhythm-changes/practice")
    expect(locations).not_to include(a_string_starting_with("/keys/C/"), "/keys/Eb/chords", "/keys/Eb/scales")
    expect(locations).not_to include("/scales/major/modes/ionian", "/keys/Eb/scales/major/modes/ionian")
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

  describe "titles and descriptions" do
    def head(name)
      document = Nokogiri::HTML(response.body)
      name == :title ? document.at_css("title").text : document.at_css("meta[name=description]")["content"]
    end

    it "names a chord by the symbol people search for, and describes it from its notes" do
      get "/keys/Eb/chords/dominant-7"

      expect(head(:title)).to eq("Eb7 Chord (Eb Dominant 7) · Jazzity")
      expect(head(:description)).to start_with("Eb7 chord (Eb Dominant 7): the notes Eb G Bb Db, 14 piano voicings")
    end

    it "gives the page in each key a description of its own, short enough for a search result" do
      descriptions = ["/chords/dominant-7", "/keys/Eb/chords/dominant-7", "/keys/Eb/chords/dominant-7/voicings/type-a",
        "/keys/Eb/scales/major", "/keys/Eb/scales/major/modes/dorian", "/keys/F/progressions/major-ii-v-i",
        "/progressions/rhythm-changes/practice"].map do |path|
        get path
        head(:description)
      end

      expect(descriptions).to eq(descriptions.uniq)
      expect(descriptions.map(&:length)).to all(be <= 160)
    end

    it "names scales, modes and voicings in full" do
      {"/scales/whole-tone" => "C Whole Tone Scale", "/keys/Eb/scales/major/modes/dorian" => "F Dorian Scale",
       "/scales/blues/modes/minor-blues" => "A Minor Blues Scale", "/keys/Eb/chords/dominant-7/voicings/type-a" => "Eb7 Type A Voicing",
       "/keys/Eb/chords/dominant-7/voicings" => "All Eb7 Voicings"}.each do |path, title|
        get path
        expect(head(:title)).to eq("#{title} · Jazzity"), path
      end
    end
  end

  describe "written descriptions" do
    def prose
      Nokogiri::HTML(response.body).css(".prose").text.squish
    end

    it "says what a chord is made of and where it's played" do
      get "/keys/Eb/chords/dominant-7"

      expect(prose).to include("Eb Dominant 7, written Eb7, is built from Eb, G, Bb and Db: the root, major 3rd, 5th and minor 7th.")
      expect(prose).to include("Its 3rd and 7th, G and Db, are its guide tones")
      expect(prose).to include("A7, a tritone away")
      expect(prose).to include("the V7 of the Major ii-V Progression in Ab")
      expect(page_links).to include("/keys/A/chords/dominant-7", "/keys/Ab/progressions/major-ii-v")
    end

    it "says what a voicing's notes are to its chord" do
      get "/keys/Eb/chords/dominant-7/voicings/type-a"

      expect(prose).to include("stacks G, Bb, Db and F from the bottom up: the major 3rd, 5th, minor 7th and 9th of the chord")
      expect(prose).to include("It leaves out the root, Eb")
      expect(prose).to include("The other for Eb7 is Type B.")
    end

    it "relates a mode to its parent scale" do
      get "/keys/Eb/scales/major/modes/dorian"
      expect(prose).to include("F Dorian is the 2nd mode of the Eb Major Scale: its notes, Eb F G Ab Bb C D, played from F.")

      get "/keys/Eb/scales/major"
      expect(prose).to include("F Dorian from the 2nd")
    end

    def page_links
      Nokogiri::HTML(response.body).css(".prose a").map { |link| link["href"] }
    end
  end
end
