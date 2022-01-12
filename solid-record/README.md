# Solid::Record

## Overview

An opinionated persistence library.

## Features

Directories are a model and the children files that are pluralized are have_many's of a type that is equal 
to the name of the file, e.g. project/users.yml will manifest as Project has_many :users. If there is a subdirectory
 it is a recursive `belongs_to`

If there is a singular name for a file:

- That is assumed to be the configured type OR if the file specifies a type then it will be CAST into that record
- If there is a directory of the same name any records in there follow the same naming convention
- If all non plural named files are to be of the same type then set that on the mapping

so let's say you have:
```bash
<root>/users/joe.yml
<root>/users/joe/profile.yml
<root>/users/profiles.yml
<root>/blogs.yml
<root>/blogs/posts.yml
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'solid-record'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install solid-record

## How it works

After defining ... call SolidRecord::DataStore.setup (maybe change to load)

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

## Other Gems

- https://github.com/joker1007/yaml_vault
- https://github.com/nicotaing/yaml_record


## Usage

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake none` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/solid-record.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
