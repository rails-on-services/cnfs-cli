# frozen_string_literal: true

# Modify a new Rails app to become a Ros service
# NOTE: Dir.pwd returns dummy_path while destination_root returns the app path
def source_paths
  [user_path.join('templates'), source_path.join('templates'), core_path.join('templates'),
   source_path, core_path, internal_path] + Array(super)
end

def user_path
  Pathname.new(destination_root).join('../../lib/generators/service')
end

def source_path
  views_path.join('app')
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

require_relative 'core/profile'
@profile = Profile.new(@app_name || name, self, options.dup)

# From core generator:
apply('core/gems.rb')
apply('core/postgres.rb')
apply('core/readme.rb')

# Include the ros core and sdk and project's core and sdk
gem 'ros-core', path: "#{@profile.ros_lib_path}/core"
gem 'ros_sdk', path: "#{@profile.ros_lib_path}/sdk"
# NOTE: The empty group is to put a separator between the above gems and the ones below.
# Without this, rails template will put them in alphabetical order which is a problem
gem_group(:development) do
end
gem "#{@profile.platform_name}-core", path: "#{@profile.lib_path}/core"
gem "#{@profile.platform_name}_sdk", path: "#{@profile.lib_path}/sdk"

# Modify spec/dummy or app Base Classes
apply('core/app_classes.rb')
apply('app/initializers.rb')

apply('core/routes.rb')
template('app/models/tenant.rb')

# Write seed files for tenants, etc
template('db/seeds/development/tenants.seeds.rb')
template('db/seeds/development/data.seeds.rb')

template('config/sidekiq.yml')
template('doc/open_api.yml')

apply('core/rspec.rb')

after_bundle do
  generate 'rspec:install'
  run 'spring stop'
end

directory('files', '.')
# copy_file 'defaults/files/Procfile', 'Procfile'
# template 'defaults/files/tmuxinator.yml', '.tmuxinator.yml'
