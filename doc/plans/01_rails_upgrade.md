# Rails 8 Upgrade Plan (Jazzity)

Date: 2026-01-03

## Current State (from repo analysis)
- Rails 3.2.21
- Ruby version unspecified (no `.ruby-version`)
- DB adapter: `mysql2` in `Gemfile`, but `config/database.yml` missing
- Assets: CoffeeScript, Sprockets, jQuery, jQuery UI, Compass + Susy, SCSS
- Views: Haml + simple_form
- Uploads: both `paperclip` and `carrierwave`
- Deprecated Rails patterns: `before_filter`, `scoped`, hash-rocket conditions, `has_one :conditions`, `find_by_name`, `secret_token` initializer, `identity_map`, `whiny_nils`, `serve_static_assets`, `best_standards_support`
- Tests: RSpec 3.1 + factory_girl, capybara, shoulda-matchers

## Target Choices (modern defaults)
- Rails 8.x
- SQLite for now
- Active Storage for uploads (replace paperclip/carrierwave)
- Zeitwerk autoloading
- ES modules for JS (Importmap or jsbundling-rails)
- Modern SCSS/CSS (remove Compass/Susy)
- Rails encrypted credentials

## Phased Upgrade Plan

### Phase 0 — Baseline + Inventory
- Create `config/database.yml` for SQLite and swap `mysql2` → `sqlite3`
- Add `.ruby-version` with a Rails 8-compatible Ruby
- Boot Rails 3.2 app on SQLite (as baseline)

### Phase 1 — Rails 3.2 → 4.2
- Update gems to Rails 4.2-compatible versions
- Replace deprecated APIs:
  - `before_filter` → `before_action`
  - `scope :x, where(...)` → `scope :x, -> { where(...) }`
  - `Model.scoped` → `Model.all`
  - `find_by_name` → `find_by(name: ...)`
  - `has_one :conditions` → scoped association `-> { where(...) }`
- Add Strong Parameters to controllers
- Remove deprecated configs (`identity_map`, `include_root_in_json`, `whiny_nils`, `serve_static_assets`, etc.)
- Run `rails app:update` and reconcile configs

### Phase 2 — Rails 4.2 → 5.2
- Enable encrypted credentials; remove `config/initializers/secret_token.rb`
- Update migrations defaults for Rails 5.2
- Introduce Active Storage and begin attachment migration
- Update test dependencies (factory_girl → factory_bot, RSpec + Capybara versions)

### Phase 3 — Rails 5.2 → 6.1
- Fix autoloading for Zeitwerk (rename files/classes under `lib/` and elsewhere)
- Remove old autoload hacks

### Phase 4 — Rails 6.1 → 7.1
- Apply new defaults via `rails app:update`
- Update security headers, cookie serializer, `config.load_defaults`
- Resolve deprecations and behavior changes

### Phase 5 — Rails 7.1 → 8.0
- Align with Rails 8 defaults and deprecations
- Final gem compatibility pass

## Modernization Tasks (work alongside phases)

### Assets / Frontend
- Remove Compass/Susy, move to modern SCSS + Grid/Flexbox
- Replace CoffeeScript with ES modules
- Replace jQuery UI/autocomplete with modern JS (Stimulus or vanilla)

### Uploads
- Pick **Active Storage** and migrate `paperclip`/`carrierwave`
- Remove both legacy upload gems once migration complete

### Gem Audit
- Remove obsolete gems: `compass-*`, `html5-rails`, `coffee-rails`
- Review/replace: `fancy-buttons`, `RedCloth`, `curb`
- Validate external API gems (`twitter`, `itunes`, `amazon-ecs`) for modern API changes

## Risks / Areas of Attention
- Zeitwerk naming + `lib/` autoloading
- Asset pipeline migration (Compass/Susy/jQuery UI)
- Dual upload system (paperclip + carrierwave)
- API client compatibility

## Verification Checklist (each phase)
- `bundle exec rails c`
- `bundle exec rails routes`
- `bundle exec rspec`
- `bundle exec rails assets:precompile`

## Next Step Options
1) Generate SQLite `config/database.yml` and `.ruby-version`
2) Prepare minimal Rails 4.2 upgrade branch with compatibility fixes
3) Enumerate exact file-level API changes before upgrading
