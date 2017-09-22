require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    through_options = assoc_options[through_name]

    define_method(name) do
      source_options = through_options.model_class.assoc_options[source_name]
      DBConnection.execute(<<-SQL)
        SELECT
          #{through_options.model_class.table_name}.*
        FROM
          #{through_options.model_class.table_name}
      hash = through_options..parse_all(source_options)
      through_options.model_class.new(hash)
    end
  end
end
