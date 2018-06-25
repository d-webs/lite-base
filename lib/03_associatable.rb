require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor :foreign_key, :class_name, :primary_key

  def model_class
    self.class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions

  def initialize(name, options = {})
    defaults = {
      foreign_key: "#{name}_id".to_sym,
      class_name: name.to_s.camelcase,
      primary_key: :id
    }

    defaults = defaults.merge(options)

    self.foreign_key = defaults[:foreign_key]
    self.class_name = defaults[:class_name]
    self.primary_key = defaults[:primary_key]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
      foreign_key: "#{self_class_name.downcase}_id".to_sym,
      class_name: name.to_s.singularize.camelcase,
      primary_key: :id
    }

    defaults = defaults.merge(options)

    self.foreign_key = defaults[:foreign_key]
    self.class_name = defaults[:class_name]
    self.primary_key = defaults[:primary_key]
  end
end

module Associatable

  def belongs_to(name, options = {})
    options_object = BelongsToOptions.new(name, options)

    define_method(name) {
      options.model_class.where(
        id: self.send(options_object.foreign_key)
      ).first
    }

    assoc_options[name] = options_object
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.to_s, options)
    # debugger
    define_method(name) {
      options.model_class.where(
        options.foreign_key => self.send(options.primary_key)
      )
    }
  end

  def assoc_options
    @assoc_options ||= {}
  end

end

class SQLObject
  extend Associatable
end
