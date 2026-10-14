# One chord in a progression. `index` is the number of semitones from the
# key to the chord's root and `degree` (1-7) the scale degree it is spelled
# from, so the ii in E is F# (index 2, degree 2) and the #iv°7 in Bb is E
# (index 6, degree 4). When no degree is given it is read from the index,
# see Key::DegreeLetterOffsets.
class ProgressionComponent < ActiveRecord::Base
  belongs_to :progression
  belongs_to :chord

  before_validation :default_degree

  validates :index, inclusion: {in: 0..11}
  validates :degree, inclusion: {in: 1..7}

  def to_s
    chord.to_s
  end

  # The root of this component's chord when the progression is in `key`.
  def root_in(key)
    (key || Key.default).degree_root(index, degree - 1)
  end

  # The key a progression is in when this component's chord has `root`.
  def key_from_root(root)
    root.shifted(-index, 1 - degree)
  end

  def all_chords
    all_chords_in_key(Key.default)
  end

  # The chord on its root in `key`: a copy, since components preloaded
  # together share one record for each chord.
  def all_chords_in_key(key)
    if chord
      [chord.clone.in_key_of(root_in(key))]
    end
  end

  private

  def default_degree
    self.degree ||= Key::DegreeLetterOffsets[index % 12] + 1 if index
  end
end
