class DropTunes < ActiveRecord::Migration[8.0]
  def change
    drop_table :tune_progressions
    drop_table :tunes
  end
end
