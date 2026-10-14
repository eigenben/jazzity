require "spec_helper"

RSpec.describe "Choosing voicings", type: :request do
  let(:progression) { Progression.find_by!(slug: "major-ii-v") }
  let(:first_voicing) { progression.chords.first.voicings.first }

  it "renders a progression with a voicing picked for a chord" do
    get progression_path(progression), params: {v: {"0" => first_voicing.id, "1" => "<"}}

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(%(<option selected="selected" value="#{first_voicing.id}">))
  end

  it "voice-leads every chord when nothing is picked" do
    get progression_path(progression)
    staff = Nokogiri::HTML(response.body).at_css(".feature [data-controller=staff]")

    expect(JSON.parse(staff["data-staff-chords-value"]).size).to eq(2)
  end

  it "ignores malformed choices" do
    get progression_path(progression), params: {v: "nonsense"}
    expect(response).to have_http_status(:ok)

    get progression_path(progression), params: {v: {"0" => {"nested" => "1"}}}
    expect(response).to have_http_status(:ok)
  end

  it "renders a chord sequence with voicing choices" do
    get chord_sequence_path("Dm7,G7,Cmaj7"), params: {v: {"0" => "<", "1" => "<", "2" => "<"}}
    expect(response).to have_http_status(:ok)
  end
end
