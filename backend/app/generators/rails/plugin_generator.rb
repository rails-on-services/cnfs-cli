# frozen_string_literal: true

# Modify a new Rails plugin to become a CNFS service
# NOTE: Dir.pwd returns dummy_path while destination_root returns the app path
def source_paths
  [user_path.join('templates'), source_path.join('templates'), core_path.join('templates'),
   source_path, core_path, internal_path.join('core')] + Array(super)
end

def user_path
  Pathname.new(destination_root).join('../../lib/generators/service')
end

def source_path
  views_path.join('plugin')
end

def core_path
  views_path.join('core')
end

def views_path
  internal_path.join('../../views/rails')
end

def internal_path
  Pathname.new(__dir__)
end

# require_relative '../../rails/core/profile'
require_relative 'core/profile'
@profile = Profile.new(@app_name || name, self, options.dup)

# From core generator:
apply('gems.rb')
apply('postgres.rb')
apply('readme.rb')
apply('gemspec.rb')

gem "#{@profile.platform_name}-core", path: '../../lib/core'
gem "#{@profile.platform_name}_sdk", path: '../../lib/sdk'

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
insert_into_file @profile.config_file, before: 'require' do
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

# The rails plugin generator doesn't seem to support the 'after_bundle' method
# after_bundle do
#   generate 'rspec:install'
#   run 'spring stop'
# end
