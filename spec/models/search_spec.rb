require "spec_helper"

RSpec.describe Search do
  def destination(query)
    described_class.new(query).destination
  end

  def title_of(query)
    destination(query)&.title
  end

  def groups_for(query)
    described_class.new(query).grouped_results.transform_values { |results| results.map(&:label) }
  end

  describe "#destination" do
    it "goes to chords named by symbol" do
      expect(title_of("Bbm7")).to eq("Bb Minor 7")
      expect(title_of("BbM7")).to eq("Bb Major 7")
      expect(title_of("C maj7")).to eq("C Major 7")
      expect(title_of("Eb")).to eq("Eb Major Triad")
    end

    it "goes to scales and modes named with a key" do
      expect(title_of("dorian D")).to eq("D Dorian")
      expect(title_of("C major")).to eq("C Major Scale")
      expect(title_of("Ab Lydian Augmented")).to eq("Ab Lydian Augmented")
    end

    it "goes to a mode or scale named without a key when nothing else has that name" do
      expect(destination("lydian")).to be_a(Mode)
      expect(destination("whole tone")).to be_a(Scale)
      expect(destination("blues")).to be_nil
    end

    it "goes to the progression roman numerals match best" do
      expect(title_of("ii V I in Eb")).to eq("Major ii-V-I Progression in Eb")
      expect(title_of("ii V")).to eq("Major ii-V Progression")
      expect(title_of("251")).to eq("Major ii-V-I Progression")
    end

    it "builds a chord sequence from roman numerals no progression matches" do
      expect(destination("I iii IV V").name).to eq("Cmaj7, Em7, Fmaj7, G7")
    end

    it "tells notes from chords" do
      expect(destination("C E G")).to be_a(NoteSequence)
      expect(destination("Dm7 G7 C")).to be_a(ChordSequence)
      expect(destination("D F A C, G B D F")).to be_a(ChordNoteSequence)
    end

    it "goes to the only progression a name matches, in its home key unless another is named" do
      expect(title_of("rhythm changes")).to eq("Rhythm Changes in Bb")
      expect(title_of("rhythm changes in C")).to eq("Rhythm Changes in C")
      expect(title_of("jazz blues in Eb")).to eq("Jazz Blues in Eb")
      expect(title_of("backdoor")).to eq("Backdoor ii-V-I Progression")
    end

    it "corrects misspelled words" do
      search = described_class.new("dorain")
      expect(search.destination.name).to eq("Dorian")
      expect(search.note).to eq("Showing results for “dorian”.")
      expect(destination("mixolidian").name).to eq("Mixolydian")
    end

    it "notes that a slash chord's bass isn't shown" do
      search = described_class.new("C7/E")
      expect(search.destination.title).to eq("C Dominant 7")
      expect(search.note).to include("bass note (E)")
    end
  end

  describe "#grouped_results" do
    it "groups everything a name matches by kind" do
      expect(groups_for("blues").keys).to eq(["Scales & modes", "Progressions"])
      expect(groups_for("minor").keys).to eq(["Chords", "Scales & modes", "Progressions"])
      expect(groups_for("altered")).to include("Chords" => ["C7alt"])
      expect(groups_for("altered")["Scales & modes"]).to include("B Super Locrian")
    end

    it "matches canonical names only, not every key" do
      expect(groups_for("bebop").values.flatten).to contain_exactly("C Major Bebop", "C Dominant Bebop", "Bebop Blues in F", "Bebop Rhythm Changes in Bb")
    end

    it "shows results in the key the query names" do
      expect(groups_for("Eb bebop").values.flatten).to contain_exactly("Eb Major Bebop", "Eb Dominant Bebop", "Bebop Blues in Eb", "Bebop Rhythm Changes in Eb")
    end

    it "finds nothing for nonsense" do
      expect(described_class.new("xyzzy").destination).to be_nil
      expect(groups_for("xyzzy")).to be_empty
    end

    it "doesn't read a query longer than MAX_LENGTH" do
      long = (["dorian"] * 100).join(" ")
      expect(long.length).to be > Search::MAX_LENGTH
      expect(described_class.new(long).destination).to be_nil
      expect(described_class.new(long).results).to be_empty
      expect(described_class.new(long).suggestions).to be_empty
    end
  end

  describe "#suggestions" do
    def labels(query)
      described_class.new(query).suggestions.map { |result| "#{result.label} — #{result.detail}" }
    end

    it "suggests what the text parses as, with what it is" do
      expect(labels("Cmaj7").first).to eq("Cmaj7 — C Major 7 chord")
      expect(labels("ii-V-I").first).to eq("Major ii-V-I — progression")
    end

    it "suggests names the text starts" do
      expect(labels("dor")).to include("D Dorian — scale")
      expect(labels("Eb dor")).to include("Eb Dorian — scale")
    end

    it "suggests chords in a key run into the symbol" do
      expect(labels("Ebma")).to include("Ebmaj7 — Eb Major 7 chord")
    end
  end
end
