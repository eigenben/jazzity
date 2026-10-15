# Voicings too wide for one hand (upper structures, So What chords) are
# split between the hands at a fixed point in their family.
class AddLeftHandTonesCountToVoicingFamilies < ActiveRecord::Migration[8.1]
  def change
    add_column :voicing_families, :left_hand_tones_count, :integer
  end
end
