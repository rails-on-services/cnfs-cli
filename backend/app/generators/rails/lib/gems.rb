# frozen_string_literal: true

# gems.rb

comment_lines 'Gemfile', "gem 'tzinfo-data'"
comment_lines 'Gemfile', "gem 'puma'"

gem_group :production do
  gem 'puma'
end

gem 'awesome_print'
gem 'pry-rails'

gem_group :development, :test do
  gem 'brakeman', require: false
  gem 'faker'
  gem 'pry-byebug'
  gem 'pry-stack_explorer'
end
