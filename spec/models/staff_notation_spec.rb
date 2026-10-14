require "spec_helper"

RSpec.describe StaffNotation do
  it "replaces a chord reference with staff markup for that chord" do
    html = described_class.parse("Try {{Ebmaj7}} here.")
    expect(html).to start_with("Try <div class=\"staff\"")
    expect(html).to include("&quot;Eb/4&quot;,&quot;G/4&quot;,&quot;Bb/4&quot;,&quot;D/5&quot;")
    expect(html).to end_with("</div> here.")
  end

  it "writes scales as a run of single notes" do
    expect(described_class.parse("{{C Major Scale}}")).to include("[[&quot;C/4&quot;],[&quot;D/4&quot;]")
  end

  it "leaves unrecognized references as plain text" do
    expect(described_class.parse("{{<b>nothing</b>}}")).to eq("<b>nothing</b>")
  end

  it "leaves text without references alone" do
    expect(described_class.parse("Just text.")).to eq("Just text.")
  end
end
