# frozen_string_literal: true
# in_root is the actual root
# 1. application stand alone
# 2. application that wraps a plugin from a plugin repository

# From core generator:
remove_file('Gemfile')
create_file('Gemfile')
# TODO: gems may by only for the core gem since the service rely on the partent Gemfile
# apply('gems.rb')
apply('postgres.rb')
apply('readme.rb')

# Include the ros core and sdk and project's core and sdk
# TODO: This should be sent in as an ENV
if cnfs.wrapped_repository_name
  gem 'ros-core', path: "#{cnfs.wrapped_repository_path}/#{cnfs.wrapped_repository_name}/core"
  gem 'ros_sdk', path: "#{cnfs.wrapped_repository_path}/#{cnfs.wrapped_repository_name}/sdk"
  # NOTE: The empty group is to put a separator between the above gems and the ones below.
  # Without this, rails template will put them in alphabetical order which is a problem
  gem_group(:development) do
  end
end

gem "#{cnfs.repository_name}-core", path: "#{@lib_path}/core"
gem "#{cnfs.repository_name}_sdk", path: "#{@lib_path}/sdk"

# Modify spec/dummy or app Base Classes
apply('app_classes.rb')
apply('initializers.rb')

apply('routes.rb')
template('app/models/tenant.rb')

# Write seed files for tenants, etc
template('db/seeds/development/tenants.seeds.rb')
template('db/seeds/development/data.seeds.rb')

template('config/sidekiq.yml')
template('doc/open_api.yml')

apply('rspec.rb')
# binding.pry

FileUtils.mv('Gemfile', 'Gemfile.dev')
directory('files', '.')
after_bundle do
  generate 'rspec:install'
  run 'spring stop'
end

# copy_file 'defaults/files/Procfile', 'Procfile'
# template 'defaults/files/tmuxinator.yml', '.tmuxinator.yml'
