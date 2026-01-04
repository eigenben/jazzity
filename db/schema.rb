# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_01_04_235616) do
  create_table "chord_qualities", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.string "slug"
    t.index ["slug"], name: "index_chord_qualities_on_slug"
  end

  create_table "chord_scales", force: :cascade do |t|
    t.integer "chord_id"
    t.integer "mode_id"
    t.integer "offset", default: 0, null: false
    t.integer "strength", default: 1
    t.text "information"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chord_id"], name: "index_chord_scales_on_chord_id"
    t.index ["mode_id"], name: "index_chord_scales_on_mode_id"
  end

  create_table "chord_symbols", force: :cascade do |t|
    t.integer "chord_id"
    t.string "name"
    t.boolean "case_sensitive", default: false
    t.integer "strength"
    t.boolean "primary", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chord_id"], name: "index_chord_symbols_on_chord_id"
    t.index ["name"], name: "index_chord_symbols_on_name"
  end

  create_table "chords", force: :cascade do |t|
    t.integer "chord_quality_id"
    t.integer "parent_id"
    t.string "name"
    t.text "synonyms"
    t.text "information"
    t.string "tone_values", limit: 4000
    t.integer "chord_tones_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["chord_quality_id"], name: "index_chords_on_chord_quality_id"
    t.index ["parent_id"], name: "index_chords_on_parent_id"
    t.index ["slug"], name: "index_chords_on_slug"
  end

  create_table "forms", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["slug"], name: "index_forms_on_slug"
  end

  create_table "meters", force: :cascade do |t|
    t.string "name"
    t.integer "beats"
    t.integer "division"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["slug"], name: "index_meters_on_slug"
  end

  create_table "modes", force: :cascade do |t|
    t.integer "scale_id"
    t.integer "mode"
    t.string "name"
    t.text "synonyms"
    t.integer "dissonance"
    t.text "information"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["mode"], name: "index_modes_on_mode"
    t.index ["scale_id"], name: "index_modes_on_scale_id"
    t.index ["slug"], name: "index_modes_on_slug"
  end

  create_table "progression_components", force: :cascade do |t|
    t.integer "progression_id"
    t.integer "position"
    t.integer "chord_id"
    t.integer "index"
    t.string "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chord_id"], name: "index_progression_components_on_chord_id"
    t.index ["position"], name: "index_progression_components_on_position"
    t.index ["progression_id"], name: "index_progression_components_on_progression_id"
  end

  create_table "progression_families", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["slug"], name: "index_progression_families_on_slug"
  end

  create_table "progressions", force: :cascade do |t|
    t.integer "progression_family_id"
    t.string "name"
    t.integer "variant_of_id"
    t.integer "bars"
    t.integer "positions_per_bar", default: 4
    t.boolean "full_tune", default: false
    t.integer "meter_id"
    t.integer "form_id"
    t.string "summary"
    t.text "information"
    t.boolean "seeding", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["meter_id"], name: "index_progressions_on_meter_id"
    t.index ["progression_family_id"], name: "index_progressions_on_progression_family_id"
    t.index ["slug"], name: "index_progressions_on_slug"
  end

  create_table "scales", force: :cascade do |t|
    t.string "name"
    t.string "information"
    t.integer "symmetry_index"
    t.string "tone_values", limit: 4000
    t.integer "tones_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["slug"], name: "index_scales_on_slug"
  end

  create_table "searchables", force: :cascade do |t|
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

  create_table "voice_leadings", force: :cascade do |t|
    t.integer "from_voicing_id"
    t.integer "to_voicing_id"
    t.integer "offset"
    t.integer "changed_tones", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from_voicing_id"], name: "index_voice_leadings_on_from_voicing_id"
    t.index ["to_voicing_id"], name: "index_voice_leadings_on_to_voicing_id"
  end

  create_table "voicing_families", force: :cascade do |t|
    t.string "name"
    t.integer "voicing_tones_count", default: 0
    t.boolean "rootless", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["slug"], name: "index_voicing_families_on_slug"
  end

  create_table "voicings", force: :cascade do |t|
    t.integer "voicing_family_id"
    t.integer "chord_id"
    t.integer "parent_id"
    t.boolean "rootless", default: false
    t.string "name"
    t.integer "octave_offset", default: 0
    t.text "information"
    t.integer "voicing_tones_count", default: 0
    t.integer "upper_structure_chord_id"
    t.integer "upper_structure_chord_offset", default: 0
    t.string "tone_values", limit: 4000
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["chord_id"], name: "index_voicings_on_chord_id"
    t.index ["slug"], name: "index_voicings_on_slug"
    t.index ["voicing_family_id"], name: "index_voicings_on_voicing_family_id"
  end
end
