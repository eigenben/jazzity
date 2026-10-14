class InitialJazzModels < ActiveRecord::Migration
  def change
    create_table :chord_qualities do |t|
      t.string :name
      t.string :code
    end

    create_table :chords do |t|
      t.references :chord_quality
      t.integer :parent_id
      t.string :name
      t.text :synonyms
      t.text :information
      t.string :tone_values, :limit => 4000
      t.integer :chord_tones_count, :default => 0
      t.timestamps
    end

    add_index :chords, :chord_quality_id
    add_index :chords, :parent_id

    create_table :chord_symbols do |t|
      t.references :chord
      t.string :name
      t.boolean :case_sensitive, :default => false
      t.integer :strength
      t.boolean :primary, :default => false
      t.timestamps
    end

    add_index :chord_symbols, :chord_id
    add_index :chord_symbols, :name

    create_table :scales do |t|
      t.string :name
      t.string :information
      t.integer :symmetry_index
      t.string :tone_values, :limit => 4000
      t.integer :tones_count, :default => 0
      t.timestamps
    end

    create_table :modes do |t|
      t.references :scale
      t.integer :mode
      t.string :name
      t.text :synonyms
      t.integer :dissonance
      t.text :information
      t.timestamps
    end

    add_index :modes, :scale_id
    add_index :modes, :mode

    create_table :chord_scales do |t|
      t.references :chord
      t.references :mode
      t.integer :offset, :default => 0, :null => false
      t.integer :strength, :default => 1
      t.text :information
      t.timestamps
    end

    add_index :chord_scales, :chord_id
    add_index :chord_scales, :mode_id

    create_table :voicing_families do |t|
      t.string :name
      t.integer :voicing_tones_count, :default => 0
      t.boolean :rootless, :default => false
      t.timestamps
    end

    create_table :voicings do |t|
      t.references :voicing_family
      t.references :chord
      t.integer :parent_id
      t.boolean :rootless, :default => false
      t.string :name
      t.integer :octave_offset, :default => 0
      t.text :information
      t.integer :voicing_tones_count, :default => 0
      t.integer :upper_structure_chord_id
      t.integer :upper_structure_chord_offset, :default => 0
      t.string :tone_values, :limit => 4000
      t.timestamps
    end

    add_index :voicings, :voicing_family_id
    add_index :voicings, :chord_id

    create_table :voice_leadings do |t|
      t.integer :from_voicing_id
      t.integer :to_voicing_id
      t.integer :offset
      t.integer :changed_tones, :default => 1
      t.timestamps
    end

    add_index :voice_leadings, :from_voicing_id
    add_index :voice_leadings, :to_voicing_id

    create_table :forms do |t|
      t.string :name
      t.timestamps
    end

    create_table :tunes do |t|
      t.string :name
      t.string :alternate_name
      t.integer :based_on_progression_id
      t.integer :vehicle_id
      t.integer :meter_id
      t.string :primary_key_name, :limit => 3
      t.string :secondary_key_name, :limit => 3
      t.string :tonality, :default => "Major"  # OR: Minor
      t.string :concept, :default => "Instrumental"  # OR: Vocal
      t.integer :form_id
      t.integer :form_length
      t.string :form_lengths
      t.integer :starting_chord_id
      t.integer :ending_chord_id
      t.integer :contrafact_of_tune_id
      t.integer :tempo
      t.integer :aebersold_playalong_number
      t.text :description
      t.boolean :seeding, :default => false
      t.boolean :featured, :default => false
      t.timestamps
    end

    add_index :tunes, :vehicle_id
    add_index :tunes, :meter_id
    add_index :tunes, :primary_key_name
    add_index :tunes, :secondary_key_name
    add_index :tunes, :form_id
    add_index :tunes, :aebersold_playalong_number

    create_table :tune_progressions do |t|
      t.references :tune
      t.references :progression
      t.string :comment
      t.integer :start_measure
      t.integer :end_measure
      t.timestamps
    end

    add_index :tune_progressions, :tune_id
    add_index :tune_progressions, :progression_id

    create_table :vehicles do |t|
      t.string :name
      t.integer :parent_id
      t.timestamps
    end

    add_index :vehicles, :parent_id

    create_table :meters do |t|
      t.string :name
      t.integer :beats
      t.integer :division
      t.timestamps
    end

    create_table :progression_families do |t|
      t.string :name
      t.timestamps
    end

    create_table :progressions do |t|
      t.integer :progression_family_id
      t.string :name
      t.integer :variant_of_id
      t.integer :bars
      t.integer :positions_per_bar, :default => 4
      t.boolean :full_tune, :default => false
      t.integer :meter_id
      t.integer :form_id
      t.string :summary
      t.text :information
      t.boolean :seeding, :default => false
      t.timestamps
    end

    add_index :progressions, :meter_id
    add_index :progressions, :progression_family_id

    create_table :progression_components do |t|
      t.integer :progression_id
      t.integer :position
      t.integer :chord_id
      t.integer :index
      t.string :comment
      t.timestamps
    end

    add_index :progression_components, :progression_id
    add_index :progression_components, :position
    add_index :progression_components, :chord_id
  end
end
