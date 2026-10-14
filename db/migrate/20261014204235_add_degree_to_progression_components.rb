# A component's `index` says how many semitones its root is above the key;
# `degree` (1-7) says which letter it is spelled with, so that a chord on
# index 1 can be a bII (Db in C) or a #I (C#).
class AddDegreeToProgressionComponents < ActiveRecord::Migration[8.1]
  def change
    add_column :progression_components, :degree, :integer
  end
end
