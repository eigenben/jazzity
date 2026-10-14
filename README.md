# Jazzity

[![CI](https://github.com/eigenben/jazzity/actions/workflows/ci.yml/badge.svg)](https://github.com/eigenben/jazzity/actions/workflows/ci.yml)

A jazz theory reference that works in every key. Look up a chord, scale or progression and see it written out on the staff, along with the scales that fit it and the voicings players use. You can also type the notes you're holding and Jazzity tells you which chords they spell.

![Jazzity home page](docs/screenshots/home.png)

## What it does

- **Chords**: every chord quality in all twelve keys, with its intervals, alternate symbols, the scales that fit it, and common voicings on a grand staff.
- **Scales and modes**: parent scales (major, melodic minor, diminished, bebop…) and the modes built on each degree.
- **Progressions**: ii-V-Is, blues forms and rhythm changes, voiced so each chord moves smoothly to the next. You can pick a specific voicing for any chord.
- **Search that understands notation**: `Ebmaj7`, `C7alt`, `Eb Lydian Augmented`, `Dm7 G7 Cmaj7` or `D F A C, G B D F` all resolve to the right thing.

| Eb major 7 in context | A ii-V-I in F, voice-led (dark mode) |
| --- | --- |
| ![Chord page](docs/screenshots/chord.png) | ![Progression page](docs/screenshots/progression-dark.png) |

## How it works

The theory lives in plain Ruby domain objects in `app/models`, rather than in lookup tables:

- **`Key`** models the 12 pitch classes and their enharmonic spellings. Each key has a chromatic index and a letter index, so transposing Eb up a major third gives G rather than F##.
- **`Tones`** is an immutable collection of chord or scale degrees stored relative to C. `in_key_of` and `in_mode` return new collections, so one chord record can be shown in any key, and a scale can be rotated into any of its modes.
- **`Chord`**, **`Scale`**, **`Mode`** and **`Voicing`** are Active Record models that share that tone math through the `Toneable` and `KeyContext` concerns.
- **`NoteSequence`**, **`ChordSequence`** and **`ChordNoteSequence`** parse free-form input ("C E G", "Dm7 G7 Cmaj7") and work out which chords, scales and progressions it matches.
- **`VoiceLeading`** stores which voicing of one chord moves smoothly to which voicing of the next, at each root movement, and uses that to voice a whole progression.

All content is seed data in `db/seeds`. Staff notation is drawn in the browser by a small Stimulus controller using [VexFlow](https://github.com/vexflow/vexflow).

## Tech stack

- Ruby 4.0, Rails 8.1, SQLite
- Hotwire (Turbo and Stimulus) with importmap, so there's no Node build step
- VexFlow 5 for music notation
- RSpec, Capybara and shoulda-matchers; RuboCop, Brakeman and bundler-audit in CI

## Getting started

You need Ruby 4.0.2 (see `.ruby-version`).

```bash
git clone https://github.com/eigenben/jazzity.git
cd jazzity
bin/setup
```

`bin/setup` installs gems, creates and seeds the database, and starts the server at http://localhost:3000.

## Tests and checks

```bash
bundle exec rspec   # specs, including a crawl of every page reachable from the home page
bin/ci              # everything CI runs: RuboCop, security audits and specs
```

## Running with Docker

The production image includes the seeded database, so it needs no setup:

```bash
docker build -t jazzity .
docker run -p 3000:80 -e RAILS_FORCE_SSL=false jazzity
```

In production behind an SSL-terminating proxy, leave `RAILS_FORCE_SSL` unset and provide a stable `SECRET_KEY_BASE`.

## History

Jazzity started in 2010 as a Rails 3 app. In 2026 it was brought up to date: Ruby 4.0 and Rails 8.1, the jQuery/Sprockets frontend replaced with Hotwire and VexFlow 5, and a long-standing bug fixed where chords were always written in C whatever key you asked for.
