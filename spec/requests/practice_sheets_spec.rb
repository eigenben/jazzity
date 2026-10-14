require "spec_helper"

feature "Practice sheets" do
  def keys
    all(".practice-key-title").map { |title| title.text.split.last }
  end

  def staves
    all(".practice-key .staff").map { |staff| JSON.parse(staff["data-staff-chords-value"]) }
  end

  scenario "Following the link from a progression to all twelve keys" do
    visit "/progressions/major-ii-v-i?family=guide-tones"
    click_link "Practice in all 12 keys"

    expect(page).to have_current_path("/progressions/major-ii-v-i/practice?family=guide-tones")
    expect(page).to have_css("h1", text: "Major ii-V-I in all 12 keys")
  end

  scenario "Practicing the ii-V-I round the cycle of fourths" do
    visit "/progressions/major-ii-v-i/practice"

    expect(keys).to eq(%w[C F Bb Eb Ab Db Gb B E A D G])
    expect(staves.size).to eq(12)
    expect(staves.map { |chords| chords.map { |chord| chord["symbol"] } }.values_at(0, 1, 7)).to eq([%w[Dm7 G7 Cmaj7 Cmaj7], %w[Gm7 C7 Fmaj7 Fmaj7], %w[C#m7 F#7 Bmaj7 Bmaj7]])
    expect(staves.first.map { |chord| chord["bass"] }).to eq([%w[D/2], %w[G/2], %w[C/3], %w[C/3]])
    expect(find("input[name=order][value=fourths]")).to be_checked
  end

  scenario "Going through the keys chromatically or by whole steps, from the progression's key" do
    visit "/keys/Eb/progressions/major-ii-v-i/practice?order=chromatic"
    expect(keys).to eq(%w[Eb E F Gb G Ab A Bb B C Db D])

    visit "/progressions/major-ii-v-i/practice?order=whole-steps"
    expect(keys).to eq(%w[C D E Gb Ab Bb Db Eb F G A B])

    visit "/progressions/major-ii-v-i/practice?order=sideways"
    expect(keys.first(3)).to eq(%w[C F Bb])
  end

  scenario "Voicing every key in a family" do
    visit "/progressions/major-ii-v-i/practice?family=guide-tones"

    expect(find("input[name=family][value=guide-tones]")).to be_checked
    expect(page).to have_css(".subtitle", text: "Guide tone voicings · Round the cycle of fourths")
    expect(staves.flatten.map { |chord| chord["treble"].size }.uniq).to eq([2])
  end

  scenario "Practicing a whole tune form" do
    visit "/progressions/rhythm-changes/practice"

    expect(keys.size).to eq(12)
    expect(staves.map { |chords| chords.sum { |chord| chord["beats"] } }.uniq).to eq([32 * 4])
    expect(all(".practice-key .staff").map { |staff| staff["data-staff-max-bars-per-line-value"] }.uniq).to eq(["8"])
  end
end
