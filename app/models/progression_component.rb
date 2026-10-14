class ProgressionComponent < ActiveRecord::Base
  belongs_to :progression
  belongs_to :chord

  def to_s
    chord.to_s
  end

  def all_chords
    all_chords_in_key(Key.default)
  end

  def all_chords_in_key(key)
    if chord
      [chord.in_key_of((key || Key.default).shifted(index))]
    end
  end
end
