require "spec_helper"

feature "Progressions" do
  scenario "Viewing the Progressions Page" do
    visit root_path
    navigate_to "Progressions"
  end

  scenario "Viewing Rhythm Changes in Bb" do
    visit "/keys/Bb/progressions/rhythm-changes"

    chords = all(".subtitle a").map(&:text)
    expect(chords.size).to eq(53)
    expect(chords.first(16)).to eq(%w[Bb6 Gmin7 Cmin7 F7 Bb6 Gmin7 Cmin7 F7 Bb6 Bb7 Eb6 Edim7 Bb6 F7 Bb6 Bb6])
    expect(chords[30, 8]).to eq(%w[D7 D7 G7 G7 C7 C7 F7 F7])
    expect(page).to have_css(".staff[data-controller='staff']")
  end
end
