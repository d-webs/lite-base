require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    through_options = assoc_options[through_name]

    define_method(name) do
      source_options = through_options.model_class.assoc_options[source_name]

      attr_hash = DBConnection.execute(<<-SQL, self.id)
        SELECT
          #{source_options.table_name}.*
        FROM
          #{through_options.table_name}
          JOIN #{source_options.table_name}
          ON #{source_options.foreign_key} = #{source_options.table_name}.id
        WHERE
          #{source_options.table_name}.id = ?
      SQL

      source_options.model_class.new(attr_hash.first)
    end
  end
end
