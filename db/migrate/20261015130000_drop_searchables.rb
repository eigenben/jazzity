# Search parses queries and matches the names of chords, scales and
# progressions directly, so it no longer needs a table of every name in
# every key.
class DropSearchables < ActiveRecord::Migration[8.1]
  def change
    drop_table :searchables do |t|
      t.integer "parent_id"
      t.string "name"
      t.string "display_name"
      t.string "model_type"
      t.integer "model_id"
      t.string "key_name", limit: 3
      t.integer "priority", default: 1, null: false
      t.index ["key_name"], name: "index_searchables_on_key_name"
      t.index ["model_type", "model_id"], name: "index_searchables_on_model_type_and_model_id"
      t.index ["name"], name: "index_searchables_on_name"
      t.index ["parent_id"], name: "index_searchables_on_parent_id"
    end
  end
end
