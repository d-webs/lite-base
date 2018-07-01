# LiteBase

LiteBase is a lightweight ORM tool written in Ruby. This project utilizes several metaprogramming techniques to allow for a simple interface with a PostgreSQL database.

## SqlObject

This serves as the super class for all LiteBase objects. It includes all CRUD methods, including `::find`, `#update`, `#insert`, `#finalize!`, `#save`, `::all`, and more. Caching techniques are used to ensure the database does not get hit during repetitive queries.

```ruby
  def self.columns
    @columns ||= DBConnection.execute2(<<-SQL).first.map(&:to_sym)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
  end
 ``` 

>_the `::columns` method returns an array of column names for a LiteBase object. When queried twice on the same instance, the results of the query are cached in an instance variable, `@columns`._

## Searchable 

This module offers an interface for querying the database with specific filters and parameters. `::where` is the primary method in this module, although future expansions will include methods such as `where.not` and `select`.

## Associatable

This module allows for users to use this tool like a true relational database, with methods such as `#belongs_to` and `#has_many`. It relies on the `HasManyOptions` and `BelongsToOptions`, both of which are subclasses for `AssocOptions`. It also allows LiteBase objects to implement `has_many_through`. 

## Future Extensions
* Write `where` so that it is lazy and stackable. Implement a `Relation` class.
* Write an `includes` method that does prefetching 
* Write a `joins` method 
