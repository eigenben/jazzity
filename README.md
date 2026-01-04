# Jazzity

A web application for exploring jazz theory. Built with Rails 8.0 and Ruby 3.4.4.

## Overview

Jazzity provides an interactive platform for studying jazz theory concepts including:

- **Chords** - Explore chord qualities, voicings, and symbols in all keys
- **Scales & Modes** - Browse musical scales and their modes with staff notation
- **Progressions** - Study common chord progressions and their voice leading
- **Tunes** - Reference jazz standards with their harmonic structures
- **Voice Leading** - Analyze smooth transitions between chord voicings

The application allows you to explore these concepts in any key, providing both theoretical knowledge and practical musical examples.

## Tech Stack

- **Ruby**: 3.4.4
- **Rails**: 8.0.4
- **Database**: SQLite (development)
- **Testing**: RSpec, FactoryBot, Capybara, Shoulda Matchers
- **Frontend**: Turbo, Stimulus, Importmap Rails

## Getting Started

### Prerequisites

- Ruby 3.4.4
- Bundler

### Installation

1. Clone the repository:
```bash
git clone https://github.com/rubiety/jazzity.git
cd jazzity
```

2. Install dependencies:
```bash
bundle install
```

3. Set up the database:
```bash
bundle exec rake db:migrate
bundle exec rake db:seed
```

4. Start the server:
```bash
bin/rails server
```

5. Visit the application:
```
http://localhost:3000
```

## Testing

Run the full test suite:
```bash
bundle exec rake
# or
bundle exec rspec
```

Run a specific spec file:
```bash
bundle exec rspec spec/models/chord_spec.rb
```

## Database Management

- Run migrations: `bundle exec rake db:migrate`
- Seed database: `bundle exec rake db:seed`
- Reset database: `bundle exec rake db:reset`

## Key Models

- **Key**: Represents musical keys with tonal relationships
- **Chord**: Chord qualities with voicings and symbols
- **Scale**: Musical scales with modes
- **Mode**: Scale modes with chord relationships
- **Progression**: Chord progressions with components
- **Tune**: Jazz standards with harmonic analysis
- **Voicing**: Chord voicings with voice leading analysis
- **VoiceLeading**: Analysis of transitions between voicings

## Features

### Search

Comprehensive search across all jazz theory concepts with autocomplete support.

### Staff Notation

Musical notation display for chords, scales, modes, and progressions.

### Key Context

Explore any concept in any musical key (e.g., "Cmaj7", "Ab Blues Scale", "F Dorian Mode").

### Voice Leading Analysis

Examine smooth voice leading between chord voicings.
