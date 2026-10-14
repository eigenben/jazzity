require "spec_helper"

feature "Progressions" do
  scenario "Viewing the Progressions Page" do
    visit root_path
    navigate_to "Progressions"
  end

  scenario "Browsing the progressions by family in a key" do
    visit "/keys/Eb/progressions"

    expect(page).to have_css("h1", text: "Progressions in Eb")
    expect(all(".section-heading").map(&:text)).to eq(["Cadences", "Turnarounds", "Cycles & Chains", "Blues", "Tune Forms", "Vamps & Lines"])
    within("#progression_#{Progression["Backdoor ii-V-I"].id}") do
      expect(page).to have_css(".card-numerals", text: "iv7 | ♭VII7 | Imaj7 | %")
      expect(page).to have_css(".card-changes", text: "Abm7 Db7 Ebmaj7")
      expect(page).to have_link(href: "/keys/Eb/progressions/backdoor-ii-v-i")
    end
    expect(page).to have_link("A", href: "/keys/A/progressions")
    expect(page).to have_css("form[action='/analysis'] input[name=changes]")
  end

  scenario "Viewing Rhythm Changes in Bb" do
    visit "/keys/Bb/progressions/rhythm-changes"

    bars = all(".lead-sheet-bar").map { |bar| bar.all(".lead-sheet-symbol").map(&:text) }
    expect(bars.size).to eq(32)
    expect(bars.first(8)).to eq([%w[B♭6 Gm7], %w[Cm7 F7], %w[B♭6 Gm7], %w[Cm7 F7], %w[B♭6 B♭7], %w[E♭6 Edim7], %w[B♭6 F7], %w[B♭6]])
    expect(bars[16, 8]).to eq([%w[D7], [], %w[G7], [], %w[C7], [], %w[F7], []])
    expect(all(".lead-sheet-section").map { |section| section["aria-label"] }).to eq(["Section A, bars 1 to 8", "Section A, bars 9 to 16", "Section B, bars 17 to 24", "Section A, bars 25 to 32"])
    expect(first(".lead-sheet-numeral").text).to eq("I6")
    expect(page).to have_css(".staff[data-controller='staff']")
  end

  scenario "Following a chord on the lead sheet to its page in the key" do
    visit "/keys/E/progressions/major-ii-v-i"

    expect(all(".lead-sheet-symbol").map(&:text)).to eq(%w[F♯m7 B7 Emaj7])
    expect(all(".lead-sheet-numeral").map(&:text)).to eq(%w[ii7 V7 Imaj7])
    expect(page).to have_css(".lead-sheet-repeat", text: "%")

    first(".lead-sheet-chord").click
    expect(page).to have_current_path("/keys/F%23/chords/minor-7")
  end

  scenario "Seeing the variations of a blues in the same key" do
    visit "/keys/F/progressions/jazz-blues"

    within("section[aria-labelledby=variations-heading]") do
      expect(page).to have_link("Basic Blues", href: "/keys/F/progressions/basic-blues")
      expect(page).to have_link("Bird Blues", href: "/keys/F/progressions/bird-blues")
    end
  end

  scenario "Reharmonizing a turnaround and analyzing the result" do
    visit "/keys/Eb/progressions/major-i-vi-ii-v"

    within("section[aria-labelledby=reharmonize-heading]") do
      expect(all(".card-title").map(&:text)).to eq(["Tritone substitutes", "Backdoor dominants"])
      expect(first(".reharmonized strong").text).to eq("E7")
      click_on "Tritone substitutes"
    end

    expect(page).to have_current_path("/keys/Eb/chord-sequences/Ebmaj7,Cm7,Fm7,E7")
    expect(page).to have_css(".analysis-key", text: "Eb major")
    expect(all(".analysis-numeral").map(&:text)).to eq(%w[Imaj7 vi7 ii7 subV7])
  end

  scenario "Analyzing a progression's own changes" do
    visit "/keys/F/progressions/bird-blues"
    click_on "Analyze these changes"

    expect(page).to have_current_path(%r{\A/keys/F/chord-sequences/Fmaj7,Em7b5,A7,Dm7,G7,Cm7,F7,Bb7,})
    expect(page).to have_css(".analysis-key", text: "F major")
  end

  scenario "Seeing that nothing reharmonizes a modal form" do
    visit "/progressions/modal-aaba"
    expect(page).to have_css("section[aria-labelledby=reharmonize-heading] .empty")
  end
end
