require "spec_helper"

RSpec.describe "Choosing voicings", type: :request do
  let(:progression) { Progression.find_by!(slug: "major-ii-v") }
  let(:first_voicing) { progression.chords.first.voicings.first }

  def staff_chords
    staff = Nokogiri::HTML(response.body).at_css(".feature [data-controller=staff]")
    JSON.parse(staff["data-staff-chords-value"])
  end

  def checked_family
    Nokogiri::HTML(response.body).at_css("input[name=family][checked]")["value"]
  end

  it "voice-leads every chord in rootless voicings when nothing is picked" do
    get progression_path(progression)

    expect(staff_chords.size).to eq(2)
    expect(staff_chords.map { |chord| chord["symbol"] }).to eq(%w[Dm7 G7])
    expect(staff_chords.map { |chord| chord["treble"].size }).to eq([4, 4])
    expect(checked_family).to eq("4-note-rootless-type-i-ii")
  end

  it "picks voicings in the chart, keeping the page where it is" do
    get progression_path(progression)

    page = Nokogiri::HTML(response.body)
    expect(page.at_css(".feature .voicing-form + [data-controller=staff]")).to be_present
    expect(page.at_css("meta[name=turbo-refresh-scroll]")["content"]).to eq("preserve")
  end

  it "voices the progression in the family picked" do
    get progression_path(progression), params: {family: "guide-tones"}

    expect(staff_chords.map { |chord| chord["treble"].size }).to eq([2, 2])
    expect(staff_chords.map { |chord| chord["bass"].size }).to eq([1, 1])
    expect(checked_family).to eq("guide-tones")
  end

  it "plays rooted families in the left hand" do
    get progression_path(progression), params: {family: "4-note-rooted"}

    expect(staff_chords.map { |chord| chord["treble"] }).to eq([[], []])
    expect(staff_chords.map { |chord| chord["bass"].size }).to eq([4, 4])
  end

  it "falls back to rootless voicings for an unknown family" do
    get progression_path(progression), params: {family: "nonsense"}

    expect(response).to have_http_status(:ok)
    expect(staff_chords.map { |chord| chord["treble"].size }).to eq([4, 4])
  end

  it "renders a progression with a voicing picked for a chord" do
    get progression_path(progression), params: {v: {"0" => first_voicing.id, "1" => ""}}

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(%(<option selected="selected" value="#{first_voicing.id}">))
    expect(response.body).to include("<details class=\"voicing-details\" open>")
  end

  it "keeps the family and picks when changing key" do
    get progression_path(progression), params: {family: "guide-tones", v: {"0" => first_voicing.id}}

    expect(response.body).to include(%(href="/keys/F/progressions/major-ii-v?family=guide-tones&amp;v%5B0%5D=#{first_voicing.id}"))
  end

  it "ignores malformed choices" do
    get progression_path(progression), params: {v: "nonsense", family: {"x" => "1"}}
    expect(response).to have_http_status(:ok)

    get progression_path(progression), params: {v: {"0" => {"nested" => "1"}}}
    expect(response).to have_http_status(:ok)
  end

  it "carries only real families and picks into links to other keys" do
    choices = {"0" => first_voicing.id, "1" => "<b>", "x" => "1", ChordSequence::MAX_CHORDS.to_s => "1"}
    choices.merge!((2...ChordSequence::MAX_CHORDS).to_h { |position| [position.to_s, ""] })
    get progression_path(progression), params: {family: "nonsense", v: choices}

    expect(response.body).to include(%(href="/keys/F/progressions/major-ii-v?v%5B0%5D=#{first_voicing.id}"))
    expect(response.body).not_to include("nonsense", "%3Cb%3E", "v%5Bx%5D", "v%5B#{ChordSequence::MAX_CHORDS}%5D")
  end

  it "renders a chord sequence with a family and voicing choices" do
    get chord_sequence_path("Dm7,G7,Cmaj7"), params: {family: "rootless-3-note-shells", v: {"0" => "", "1" => "", "2" => ""}}

    expect(response).to have_http_status(:ok)
    expect(staff_chords.map { |chord| chord["treble"].size }).to eq([3, 3, 3])
  end
end
