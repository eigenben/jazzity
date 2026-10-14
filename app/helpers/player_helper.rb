module PlayerHelper
  # The data attributes that make an element a player (see
  # app/javascript/controllers/player_controller.js) of `chords`, each a hash
  # of MIDI notes for each hand as VoicedChord#to_playback gives them. `kind`
  # is :chord, :scale or :sequence; other values (beats_per_bar,
  # next_key_url, resume_key, loopable) are passed on as they are. The
  # `shortcut` player is the one the Space bar plays.
  def player_data(kind, chords, shortcut: false, **values)
    {
      :controller => "player",
      :player_kind_value => kind,
      :player_chords_value => chords.to_json,
      :player_shortcut_value => (true if shortcut)
    }.merge(values.compact.transform_keys { |name| :"player_#{name}_value" }).compact
  end

  # The player for voiced chords that go on to the next key round the
  # cycle of fourths after each time through, when asked to: `in_key` gives
  # the page for a key. A page playing `resume_key` carries on playing when
  # it's replaced by another with the same key (in another key or voicing).
  def sequence_player_data(playback, key:, resume_key:, beats_per_bar: 4, &in_key)
    next_key = Key.practice_order("fourths", key || Key.default).second
    player_data(:sequence, playback, shortcut: true, beats_per_bar: beats_per_bar, next_key_url: in_key.call(next_key), resume_key: resume_key)
  end

  def progression_player_data(progression, voiced_chords)
    sequence_player_data(progression.playback(voiced_chords), key: progression.key, beats_per_bar: progression.beats_per_bar, resume_key: "progression-#{progression.slug}") do |key|
      polymorphic_path(in_key(key, progression), voicing_params)
    end
  end

  def chord_sequence_player_data(sequence, voiced_chords)
    sequence_player_data(sequence.playback(voiced_chords), key: sequence.home_key, resume_key: "chord-sequence-#{sequence.chords.size}") do |key|
      polymorphic_path(in_key(key, sequence.in_key_of(key)), voicing_params)
    end
  end

  # Notes written for the staff ("Eb/4") as Pitches.
  def pitches_of(notes)
    notes.filter_map { |note| Pitch.parse(note) }
  end

  # Pitches as a chord for a player, all in the right hand.
  def playback_of(pitches)
    {:left => [], :right => pitches.map(&:midi), :names => pitches.map(&:name)}
  end

  # A chord, voicing, scale or mode as a player's chords and the pitches for
  # its keyboard (as {right:, left:}).
  def playback_for(subject)
    case subject
    when Voicing
      voiced = subject.voiced
      [[voiced.to_playback], {:right => voiced.treble, :left => voiced.bass}]
    else
      pitches = pitches_of(subject.octavized_notes)
      [[playback_of(pitches)], {:right => pitches, :left => []}]
    end
  end

  # A round play button that plays and stops its player, for a card.
  # `label` names what it plays, as in "Play Dm7".
  def play_button(label, target: "toggle", action: "player#toggle", **options)
    tag.button(play_icon, type: "button", class: ["play-button", options.delete(:class)], aria: {label: label, pressed: false},
      title: label, data: {player_target: target, action: action}, **options)
  end

  # A labelled button that plays and stops its player.
  def player_button(text, target: "toggle", action: "player#toggle", icon: play_icon, **options)
    tag.button(icon + tag.span(text), type: "button", class: ["player-button", options.delete(:class)], aria: {pressed: false},
      data: {player_target: target, action: action}, **options)
  end

  # A triangle that becomes a square while its button is pressed.
  def play_icon
    tag.svg(tag.path(class: "icon-play", d: "M4.5 2.8v10.4L13 8z") + tag.rect(class: "icon-stop", x: 3.5, y: 3.5, width: 9, height: 9, rx: 1),
      class: "icon", viewBox: "0 0 16 16", "aria-hidden": true)
  end
end
