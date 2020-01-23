# frozen_string_literal: true

# Modify a new Rails app to become a Ros service
# NOTE: Dir.pwd returns dummy_path while destination_root returns the app path
def source_paths
  ["#{user_path}/templates", "#{core_path}/templates", core_path] + Array(super)
end

def user_path
  Pathname.new(destination_root).join('../../../generators/core')
end

def core_path
  __dir__
end

require_relative 'profile'
@profile = Profile.new(name, self, options.dup)

apply('gemspec.rb')
apply('gems.rb')
apply('postgres.rb')
apply('readme.rb')

gem 'ros-core', path: "#{@profile.ros_lib_path}/core"
