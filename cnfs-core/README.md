# Cnfs::Core

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/cnfs/core`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cnfs-core'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cnfs-core

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/cnfs-core.

```ruby
# Config.setup do |config|
#   config.use_env = true
#   config.env_prefix = 'CNFS'
#   config.env_separator = '__'
#   config.merge_nil_values = false
# end
# require 'yaml_vault'
```


- Platform - The overall project is a platform
- Partitions - Backend, Frontend, Pipeline
- Components - Backend::Infra, Backend::Application, Backend::Services
- Resources - Backend::Infra::Kubernetes, Backend::Application::Servers
- Units - Backend::Infra::Kubernetes::Fluentd

- Cnfs::Platform::Partition::Component::Resource
- Cnfs::Platform::Backend::Application::Rails::Config
- Cnfs::Platform::Backend::Application::Rails::Unit

## Explained

platform.yml defines the partitions
providers.yml can be at platform or partition level

```bash
config
|-- backend
|   |-- application.yml
|   |-- infra.yml
|   |-- production
|   |   - uat
|   |       - dev1
|   `-- services.yml
|-- platform.yml
`-- providers.yml
```
