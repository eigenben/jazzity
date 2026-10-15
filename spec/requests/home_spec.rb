require "spec_helper"

feature "Home" do
  scenario "Viewing the Home Page" do
    visit root_path
  end

  scenario "Sharing a link to a page" do
    visit "/chords/major-7"

    expect(page).to have_css("meta[property='og:title'][content='Major 7']", visible: false)
    expect(page).to have_css("meta[property='og:url'][content$='/chords/major-7']", visible: false)
    expect(page).to have_css("meta[property='og:image'][content^='http'][content$='/og.png']", visible: false)
    expect(File).to exist(Rails.public_path.join("og.png"))
  end

  scenario "Trying an example progression" do
    visit root_path
    click_on "Coltrane changes"

    expect(page).to have_current_path("/progressions/coltrane-changes")
    expect(all(".lead-sheet-symbol").map(&:text).first(3)).to eq(%w[Dm7 E♭7 A♭maj7])
  end

  scenario "Analyzing example changes" do
    visit root_path
    click_on "analyze Dm7 G7 Cmaj7 A7"

    expect(page).to have_current_path("/chord-sequences/Dm7,G7,Cmaj7,A7")
    expect(page).to have_css(".analysis-key", text: "C major")
  end
end
