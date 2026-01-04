class Searchable < ActiveRecord::Base
  belongs_to :model, polymorphic: true
  belongs_to :key, optional: true
  belongs_to :parent, class_name: 'Searchable', optional: true
  has_many :children, class_name: 'Searchable', foreign_key: 'parent_id'

  default_scope { order('priority') }

  def to_s
    display_name || name
  end

  def target
    @target ||= key ? model.in_key_of(key) : model
  end

  attr_writer :target

  def key
    Key[key_name]
  end

  # REFACTOR: We should keep track of classes that include Model and do this dynamically. Also don't define methods on the class.
  def self.regenerate_all
    delete_all

    [Chord, Scale, Mode, Progression].each do |klass|
      klass.all.each(&:generate_searchables)
    end
  end

  module Model
    extend ActiveSupport::Concern

    included do
      has_many :searchables, as: :model
    end

    module ClassMethods
      def define_searchables(&block)
        define_method(:generate_searchables, &block)
      end
    end
  end
end
