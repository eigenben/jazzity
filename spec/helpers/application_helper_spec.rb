require "spec_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#in_key" do
    it "prefixes the key for keys other than C" do
      expect(helper.in_key(Key["Eb"], :chords)).to eq([Key["Eb"], :chords])
      expect(helper.in_key(Key["C"], :chords)).to eq([:chords])
      expect(helper.in_key(nil, :chords)).to eq([:chords])
    end
  end

  describe "#text_to_html" do
    it "renders Textile" do
      expect(helper.text_to_html("Some *bold* text")).to eq("<p>Some <strong>bold</strong> text</p>")
    end

    it "expands staff references" do
      expect(helper.text_to_html("{{Cmaj7}}")).to include('data-controller="staff"')
    end

    it "strips unsafe markup" do
      expect(helper.text_to_html("<script>alert(1)</script>")).not_to include("<script>")
    end
  end
end
