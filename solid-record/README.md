# Solid Record - A relational database in YAML

Solid Record is a simple relational database backed by a hierarchical file system of supported files types
powered by sqlite and ActiveRecord

Solid Record currently only supports `YAML` files, but can be extended to support other types with plugins

Directories and files are imported into a sqlite database as records in tables following a convention over
configuration approach which derives sementic meaning from the name, contents and position in the file
system relative to other files and directories

Plural names are transformed into collections of records while singular names become a single record. Records are
CAST into a specifc type based on the name of directory or file

Subdirectoreies and files contained in a directory are considered to `belong_to` the parent directory. In the same
regard, the parent directory:

- `has_many` of each directory with a plural name and `has_many` of the contents of each file with a plural name
- `has_one` of each directory and contents of a file with a singular name

Given the following:

Directory tree:

```bash
segments
|-- backend
|   |-- devevelopment.yml
|   |-- production
|   |   `-- services.yml
|   |-- staging
|   |   `-- services.yml
|   `-- staging.yml
|-- backend.yml
|-- frontend
|   `-- services.yml
|-- services.yml
`-- users.yml
```

`segments.yml`:
```yaml
singular_type: stack
```

`segments/backend.yml`:
```yaml
singular_type: environment
```

Solid Record will create:

sqlite tables: `segments`, `stacks`, `environments`, `services` and `users`

Active Record Models: `Segment`, `Stack`, `Environment`, `Service` and `User`

Active Record Associations:
- `Segment` `has_many` `:stacks`
- `class Segment has_many :services`
- `class Segment has_many :users`
- `Stack` `has_many` `:environemnts`
- `Service` `belongs_to` `:segment`
- `User` `belongs_to` `:segment`


Directories are a model and the children files that are pluralized are have_many's of a type that is equal 
to the name of the file, e.g. project/users.yml will manifest as Project has_many :users. If there is a subdirectory
 it is a recursive `belongs_to`

If there is a singular name for a file:

- That is assumed to be the configured type OR if the file specifies a type then it will be CAST into that record
- If there is a directory of the same name any records in there follow the same naming convention
- If all non plural named files are to be of the same type then set that on the mapping

[Read more](link)


## Configuration

After defining ... call

```ruby
SolidRecord::DataStore.setup (maybe change to load)
SolidRecord::Directory.create(path: 'segments')
```

## Persistence

NOTE: This should auto disable model callbacks

TODO: Need a name for the class of models. Assets maybe, but Segment makes no sense. There needs to be a name for the Directory Asset

You define the has_many associations with asset_names (but this should change).

There are no migrations. There is only the current schema. Therefore the schemas are defined in the model class
 itself which simplifies the overall implementation. you can dump a schema with

```ruby
code
```

Changes to models will be automatically persisted by calling to_yaml on the object. all attributes *except* those
 ending in `_id` will be persisted. 
To override the content written to files implement to_node_content which should return a hash; SolidRecord will convert this to YAML

ID's are not consistent over time in YAML so you cannot rely on the ID. Names need to be unique so that is the natural primary key.
To implement where files have a belongs_to relationship between them, e.g. user has_many :profiles in profile declare
both a t.references user and t.string user_name; By setting the user name SolidRecord will find the User record of
 that name and insert the ID when creating the record

[Read more](link)


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'solid-record'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install solid-record

### Integration with OneStack

SolidRecord is a core component of OneStack and requires no further configuration to work out of the box. It can
be configured with these options:

```ruby
config.this
config.that
```

### Integration with Rails

add `gem solid-record` to your project's `Gemfile`

```ruby
class Blog::Fuse < App::Fuse
end
```


## Related and Alternative Gems

- https://github.com/joker1007/yaml_vault
- https://github.com/nicotaing/yaml_record

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake none` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/cnfs-io/solid-record)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
