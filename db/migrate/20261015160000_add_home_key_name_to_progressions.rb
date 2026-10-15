# The key a progression is usually played in, as the tunes built on it are:
# Rhythm Changes in Bb, the blues in F. Blank for C.
class AddHomeKeyNameToProgressions < ActiveRecord::Migration[8.1]
  def change
    add_column :progressions, :home_key_name, :string
  end
end
