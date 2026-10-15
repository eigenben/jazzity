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
      voicing = Chord["Dm7"].voicings.find_by!(name: "Type A").in_key_of(Key["D"])
      chords, hands = helper.playback_for(voicing)

      expect(chords.first).to include(:left => [38], :right => [65, 69, 72, 76])
      expect(hands[:left].map(&:to_s)).to eq(voicing.voiced.to_staff[:bass])
      expect(hands[:right].map(&:to_s)).to eq(voicing.voiced.to_staff[:treble])
    end
  end

  describe "#progression_player_data" do
    let(:progression) { Progression["Major ii-V-I"].in_key_of(Key["Eb"]) }

    before { allow(helper).to receive(:voicing_params).and_return({}) }

    it "plays the voiced chords for as many beats as they last, with the root in the bass" do
      chords = chords_in(helper.progression_player_data(progression, progression.voiced_chords))

      expect(chords.map { |chord| chord.values_at("symbol", "beats") }).to eq([["Fm7", 4], ["Bb7", 4], ["Ebmaj7", 4], ["Ebmaj7", 4]])
      expect(chords.map { |chord| chord["left"].first % 12 }).to eq([5, 10, 3, 3])
      expect(chords.first["names"].first).to eq("F2")
    end

    it "goes on to the next key round the cycle of fourths, keeping the voicing family" do
      allow(helper).to receive(:voicing_params).and_return({:family => "guide-tones"})
      data = helper.progression_player_data(progression, progression.voiced_chords)

      expect(data[:player_next_key_url_value]).to eq("/keys/Ab/progressions/major-ii-v-i?family=guide-tones")
      expect(data[:player_resume_key_value]).to eq("progression-major-ii-v-i")
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
