require "spec_helper"

RSpec.describe PlayerHelper, type: :helper do
  def chords_in(data)
    JSON.parse(data[:player_chords_value])
  end

  describe "#player_data" do
    it "makes a player of the chords, with any other values it's given" do
      data = helper.player_data(:sequence, [{:left => [38], :right => [60]}], shortcut: true, beats_per_bar: 3, next_key_url: nil)

      expect(data).to eq(
        :controller => "player", :player_kind_value => :sequence, :player_chords_value => %([{"left":[38],"right":[60]}]),
        :player_shortcut_value => true, :player_beats_per_bar_value => 3
      )
    end
  end

  describe "#playback_for" do
    it "gives a chord's notes as they're written on its staff, in MIDI" do
      chords, hands = helper.playback_for(Chord["Ebmaj7"])

      expect(chords).to eq([{:left => [], :right => [63, 67, 70, 74], :names => %w[Eb4 G4 Bb4 D5]}])
      expect(hands[:right].map(&:to_s)).to eq(Chord["Ebmaj7"].octavized_notes)
    end

    it "gives a scale's notes from the bottom up" do
      chords, = helper.playback_for(Mode["D Dorian"])

      expect(chords.first[:right]).to eq([62, 64, 65, 67, 69, 71, 72])
    end

    it "sounds Cb and B# where they're written" do
      chords, = helper.playback_for(NoteSequence["Ab Cb Eb"])

      expect(chords.first[:right]).to eq([56, 59, 63])
    end

    it "gives a voicing in each hand, as on its staff" do
      voicing = Chord["Dm7"].voicings.find_by!(name: "Type I").in_key_of(Key["D"])
      chords, hands = helper.playback_for(voicing)

      expect(chords.first).to include(:left => [38], :right => [65, 69, 72, 76])
      expect(hands[:left].map(&:to_s)).to eq(voicing.voiced.to_staff[:bass])
      expect(hands[:right].map(&:to_s)).to eq(voicing.voiced.to_staff[:treble])
    end
  end

  describe "#play_button" do
    it "is a toggle button labelled with what it plays" do
      button = Nokogiri::HTML.fragment(helper.play_button("Play Dm7")).at_css("button")

      expect(button["aria-label"]).to eq("Play Dm7")
      expect(button["aria-pressed"]).to eq("false")
      expect(button["data-action"]).to eq("player#toggle")
    end
  end
end
