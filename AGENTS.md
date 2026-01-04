# AGENTS.md

This file provides guidance for agentic coding assistants working on this codebase.

## Project Overview

Jazzity is a Rails 8.0 web application (Ruby 3.4.4) for exploring jazz theory. It uses RSpec for testing, FactoryBot for fixtures, and follows standard Rails conventions with an emphasis on domain modeling.

## Build/Test Commands

### Running Tests
- Run all tests: `bundle exec rake` or `bundle exec rspec`
- Run a single spec file: `bundle exec rspec spec/models/chord_spec.rb`
- Run a single test at specific line: `bundle exec rspec spec/models/chord_spec.rb:15`
- Run feature specs: `bundle exec rake cucumber:ok` or `bundle exec rake cucumber:all`

### Database Commands
- Run migrations: `bundle exec rake db:migrate`
- Seed database: `bundle exec rake db:seeds`
- Reset database: `bundle exec rake db:reset`

### Server
- Start Rails server: `bin/rails server`

## Code Style Guidelines

### Models

**Class Structure:**
- Inherit from `ActiveRecord::Base` (or use modules for non-AR classes like `Key`)
- Use `extend FriendlyId` for slug support
- Include modules at the top: `extend`, then `include`
- Define associations first, then scopes, then validations, then instance methods

**Common Patterns:**
```ruby
class Model < ActiveRecord::Base
  extend FriendlyId
  include Searchable::Model
  include KeyContext

  friendly_id :name, use: :slugged

  has_many :associated_models
  belongs_to :parent_model, class_name: "Model", optional: true

  scope :featured, -> { where(featured: true) }

  validates :name, presence: true

  def to_s
    name
  end

  def self.resolve(name)
    find_by(name: name)
  end

  class << self
    alias_method :[], :resolve
  end
end
```

- Always implement `to_s` returning the most human-readable representation
- Use `class << self; alias_method :[], :resolve; end` for convenient array-like access
- Use `attr_reader` for immutable attributes in non-ActiveRecord classes
- Use hash rockets (`=>`) for hash literals with symbol keys (e.g., `{:key => value}`)

**Scopes and Queries:**
- Use lambda syntax: `scope :active, -> { where(active: true) }`
- Chain associations: `has_many :items, -> { order(position: :asc) }`
- Use `includes` for eager loading to avoid N+1 queries

### Controllers

**Structure:**
- Use `before_action` filters (not `before_filter`)
- Use `respond_to` and `respond_with` for multi-format responses
- Keep actions thin, delegate business logic to models
- Move shared lookup logic to `protected` methods

```ruby
class ResourcesController < ApplicationController
  before_action :find_resource, except: [:index, :create]
  respond_to :html, :json

  def index
    @resources = Resource.all
    respond_with @resources
  end

  protected

  def find_resource
    @resource = Resource.find_by(slug: params[:id])
  end
end
```

### Associations

- Use `class_name:` for self-referential associations: `class_name: "Chord"`
- Use `foreign_key:` when the foreign key name is non-standard
- Use `optional: true` for nullable associations
- Use dependent options for cascading deletes: `has_many :items, dependent: :destroy`

### Validations

- Use Rails macros: `validates :name, presence: true`
- For inclusion validations: `validates :status, inclusion: { in: %w(active inactive) }`
- Use custom validation methods only when macros are insufficient

### Testing (RSpec)

**Model Tests:**
```ruby
describe Model do
  context "associations" do
    it { should belong_to(:parent) }
    it { should have_many(:children) }
  end

  context "validations" do
    it { should validate_presence_of(:name) }
  end

  describe "#to_s" do
    it "returns the name" do
      expect(described_class.new(name: "Test").to_s).to eq("Test")
    end
  end
end
```

**Request/Feature Tests:**
- Use Capybara for integration tests in `spec/requests/`
- Test user flows, not implementation details

### Naming Conventions

- Classes: PascalCase (`Chord`, `KeyContext`)
- Methods/variables: snake_case (`chord_voicing_notes`, `find_key`)
- Constants: SCREAMING_SNAKE_CASE (`Letters`, `Steps`)
- Database tables: plural snake_case (`chord_qualities`)
- Foreign keys: singular snake_case with `_id` suffix (`chord_quality_id`)
- Private helper methods: underscore prefix (`_helper_method`)

### Error Handling

- Let Rails handle standard validation errors (don't rescue them)
- Use `find_by` instead of `find` when nil is acceptable
- For domain logic that might fail, consider returning nil or a result object
- Minimal exception handling - prefer guard clauses

### Code Organization

- Models in `app/models/` (one file per model)
- Controllers in `app/controllers/` (RESTful resource controllers)
- Views in `app/views/` using ERB templates
- Use partials for reusable UI components (prefix with `_`)
- Helpers in `app/helpers/` for view logic

### Import/Module Usage

- Modules in `app/models/` should be namespaced and reusable
- Use concerns in `app/models/concerns/` for shared model behavior
- Include concern modules in models with `include ConcernModule`

### View Guidelines

- ERB templates for all views
- Use partials with `render` for reusable components
- Minimal logic in views - use helpers for complex computations
- Use Turbo/Stimulus for dynamic interactions (importmap-rails setup present)

### General Principles

- Follow Ruby style guide: 2-space indentation, no trailing whitespace
- Use Ruby idioms: `&:method` syntax, safe navigation `&.`, enumerable transformations
- Prefer readability over cleverness
- DRY: extract repeated code into methods/modules
- Use descriptive names that reveal intent
- Only add comments for complex business logic, not obvious code
- Domain objects should be rich with behavior, not just data containers

### Rails-Specific

- Use `params[:id]` for slug-based lookups (thanks to FriendlyId)
- Use `render json: @object` for JSON responses
- Use `respond_with` for smart multi-format responses
- Leverage Rails conventions over configuration
- Use strong parameters in controllers when accepting form data
- Use `form_with` for forms (SimpleForm available)
