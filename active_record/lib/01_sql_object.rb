require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    @columns ||= DBConnection.execute2(<<-SQL).first.map(&:to_sym)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
  end

  def self.finalize!
    columns.each do |col|
      define_method(col) do
        self.attributes[col]
      end

      define_method("#{col}=") do |arg|
        self.attributes[col] = arg
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    attr_hashes = DBConnection.execute(<<-SQL)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
    SQL

    parse_all(attr_hashes)
  end

  def self.parse_all(results)
    results.map do |result_hash|
      self.new(result_hash)
    end
  end

  def self.find(id)
    attr_hash = DBConnection.execute(<<-SQL, id)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
      WHERE
        id = ?
    SQL

    return nil if attr_hash.empty?

    self.new(attr_hash.first)
  end

  def initialize(params = {})
    params.each do |key, val|
      attr_name = key.to_sym

      if self.class.columns.include?(attr_name)
        send("#{attr_name}=", val)
      else
        raise "unknown attribute '#{attr_name}'"
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    @attributes.values
  end

  def insert
    col_names = self.class.columns.join(',')
    question_marks = (['?'] * col_names.length).join(',')

  end

  def update
    # ...
  end

  def save
    # ...
  end
end
