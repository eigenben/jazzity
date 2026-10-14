# Voice leading is computed by VoiceLeader rather than looked up from a
# table of seeded voicing pairs.
class DropVoiceLeadings < ActiveRecord::Migration[8.1]
  def change
    drop_table :voice_leadings do |t|
      t.integer "from_voicing_id"
      t.integer "to_voicing_id"
      t.integer "offset"
      t.integer "changed_tones", default: 1
      t.timestamps
      t.index ["from_voicing_id"], name: "index_voice_leadings_on_from_voicing_id"
      t.index ["to_voicing_id"], name: "index_voice_leadings_on_to_voicing_id"
    end
  end
end
