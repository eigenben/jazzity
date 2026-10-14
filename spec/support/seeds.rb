# The jazz theory content (chords, scales, voicings, progressions) lives in
# db/seeds and is effectively reference data, so load it once for the suite.
RSpec.configure do |config|
  config.before(:suite) do
    Rails.application.load_seed
  end
end
