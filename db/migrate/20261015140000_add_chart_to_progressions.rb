# A progression is written as a chart of roman numerals in bars, such as
# "| ii7 V7 | Imaj7 |", from which its components are built.
class AddChartToProgressions < ActiveRecord::Migration[8.1]
  def change
    add_column :progressions, :chart, :text
  end
end
