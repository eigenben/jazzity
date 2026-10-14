require "spec_helper"

RSpec.describe "Analyzing chord changes", type: :request do
  def page
    Nokogiri::HTML(response.body)
  end

  def rows
    page.css(".analysis-table tbody tr").map { |row| row.css("th, td").map { |cell| cell.text.squish } }
  end

  it "shows a form for changes to analyze" do
    get analysis_path
    expect(response).to have_http_status(:ok)
    expect(page.css("form[action='/analysis'] input[name=changes]")).to be_present
  end

  it "goes to the changes' own page, at the analysis" do
    get analysis_path(changes: "Dm7 G7 Cmaj7 A7")
    expect(response).to redirect_to("/chord-sequences/Dm7,G7,Cmaj7,A7#analysis")
  end

  it "says which chords it couldn't read" do
    get analysis_path(changes: "Dm7 Xyz Cmaj7")
    expect(response).to have_http_status(:unprocessable_content)
    expect(page.css("[role=alert]").text.squish).to include("couldn't read “Xyz”")
  end

  it "asks for more than one chord" do
    get analysis_path(changes: "Dm7")
    expect(response).to have_http_status(:unprocessable_content)
    expect(page.css("[role=alert]").text).to include("at least two chords")
  end

  it "ignores changes that aren't text" do
    get analysis_path, params: {changes: {"x" => "1"}}
    expect(response).to have_http_status(:ok)
  end

  it "analyzes Dm7 G7 Cmaj7 A7 in C major" do
    get "/chord-sequences/Dm7,G7,Cmaj7,A7"

    expect(page.css(".analysis-key").text.squish).to eq("Heard in C major")
    expect(rows).to eq([
      ["Dm7", "ii7", "Subdominant"], ["G7", "V7", "Dominant"], ["Cmaj7", "Imaj7", "Tonic"], ["A7", "V7/ii", "Secondary dominant of ii"]
    ])
    expect(page.css("a.card[href='/progressions/major-ii-v-i'] .card-title").text).to eq("Major ii-V-I Progression")
    expect(page.css("a.card[href='/scales/major/modes/dorian'] .card-kind").text.squish).to eq("Over Dm7 · ii7")
    expect(page.css(".subtitle").text.squish).to eq("Dm7 G7 Cmaj7 A7")
  end

  it "names secondary dominants and tritone substitutes" do
    get "/chord-sequences/Em7b5,A7,Dm7,Db7,Cmaj7"

    expect(rows.map { |row| row[1] }).to eq(%w[iiø7/ii V7/ii ii7 subV7 Imaj7])
    expect(page.css("a.card[href='/keys/D/progressions/minor-ii-v-i']")).to be_present
    expect(page.css("a.card[href='/progressions/tritone-sub-ii-v-i']")).to be_present
    expect(page.css(".card-title").map(&:text)).to include("Db Lydian Dominant", "A Mixolydian b6")
  end

  it "hears a minor key" do
    get "/chord-sequences/Cm7,F7,Bbmaj7,Ebmaj7,Am7b5,D7,Gm6"

    expect(page.css(".analysis-key").text.squish).to eq("Heard in G minor")
    expect(rows.map { |row| row[1] }).to eq(%w[iv7 ♭VII7 ♭IIImaj7 ♭VImaj7 iiø7 V7 i6])
    expect(page.css("a.card[href='/keys/Bb/progressions/major-ii-v-i']")).to be_present
    expect(page.css("a.card[href='/keys/G/progressions/minor-ii-v-i']")).to be_present
  end

  it "analyzes the changes again in another key" do
    get "/keys/Eb/chord-sequences/Fm7,Bb7,Ebmaj7,C7"

    expect(page.css(".analysis-key").text.squish).to eq("Heard in Eb major")
    expect(rows.map { |row| row[1] }).to eq(%w[ii7 V7 Imaj7 V7/ii])
  end
end
