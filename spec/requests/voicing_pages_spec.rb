require "spec_helper"

RSpec.describe "Voicing pages", type: :request do
  def staff_chords
    staff = Nokogiri::HTML(response.body).at_css(".feature [data-controller=staff]")
    JSON.parse(staff["data-staff-chords-value"])
  end

  it "writes a rootless voicing over its root, with the chord symbol" do
    get "/keys/Eb/chords/major-7/voicings/type-a"

    expect(staff_chords).to eq([{"symbol" => "Ebmaj7", "bass" => ["Eb/2"], "treble" => ["G/4", "Bb/4", "D/5", "F/5"]}])
    expect(response.body).to include("Right hand")
  end

  it "writes a rooted voicing in the left hand" do
    get "/chords/major-7/voicings/rooted-i"

    expect(staff_chords).to eq([{"symbol" => "Cmaj7", "bass" => ["C/3", "E/3", "G/3", "B/3"], "treble" => []}])
    expect(response.body).not_to include("Right hand")
  end
end
