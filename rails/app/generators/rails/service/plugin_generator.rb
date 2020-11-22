# frozen_string_literal: true

# in_root is the actual root e,g. spec/dummy/../..
# 1. core lib for an application repository
# 2. core lib for a plugin repository
# 3. a service for a plugin repository

# From core generator:
apply('gems.rb')
apply('postgres.rb')
apply('readme.rb')
apply('gemspec.rb')

gem "#{cnfs.repo_name}-core", path: '../../lib/core'
gem "#{cnfs.repo_name}_sdk", path: '../../lib/sdk'

# Create Engine's namespaced classes
template 'app/models/%namespaced_name%/application_record.rb'
template 'app/resources/%namespaced_name%/application_resource.rb'
template 'app/policies/%namespaced_name%/application_policy.rb'
template 'app/controllers/%namespaced_name%/application_controller.rb'
template 'app/jobs/%namespaced_name%/application_job.rb'

# Modify spec/dummy or app Base Classes
apply('app_classes.rb')

# workaround for rails 6.0.0.beta2
inject_into_file 'spec/dummy/config/application.rb', "require 'rails-html-sanitizer'", after: "require_relative 'boot'\n"
remove_file("lib/#{namespaced_name}/engine.rb")
insert_into_file cnfs.config_file, before: 'require' do
  <<~RUBY
    require 'ros/core'
  RUBY
end
template('lib/%namespaced_name%/engine.rb')

apply('routes.rb')
template('app/models/tenant.rb')

# plugins throw an error on rake db:seed if this file is not present
create_file "#{options.dummy_path}/db/seeds.rb"

# Write seed files for tenants, etc
template('db/seeds/development/tenants.seeds.rb')
template('db/seeds/development/data.seeds.rb')
remove_file("lib/tasks/#{namespaced_name}_tasks.rake")
template('lib/tasks/%namespaced_name%_tasks.rake')

template 'config/sidekiq.yml'
template 'doc/open_api.yml'

apply('rspec.rb')

FileUtils.mv('Gemfile', 'Gemfile.dev')
directory('files', '.')

# The rails plugin generator doesn't seem to support the 'after_bundle' method
# after_bundle do
#   generate 'rspec:install'
#   run 'spring stop'
# end
