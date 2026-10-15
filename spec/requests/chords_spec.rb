require "spec_helper"

feature "Chords" do
  scenario "Viewing the Chords Page" do
    visit root_path
    navigate_to "Chords"
  end

  scenario "Being offered C# rather than Db where Db would need double flats" do
    visit "/chords/half-diminished"

    within(".key-picker") do
      expect(page).to have_link("C#", href: "/keys/C%23/chords/half-diminished")
      expect(page).to have_link("D#", href: "/keys/D%23/chords/half-diminished")
      expect(page).not_to have_link("Db")
      expect(page).not_to have_link("Gb")
    end

    visit "/keys/Db/chords/half-diminished"
    expect(page).to have_css(".key-picker a[aria-current=page]", text: "C#")
  end

  scenario "Being offered the usual keys where every spelling reads" do
    visit "/chords/major-7"

    expect(all(".key-picker a").map(&:text)).to eq(%w[C F Bb Eb Ab Db Gb F# B E A D G])
  end
end
