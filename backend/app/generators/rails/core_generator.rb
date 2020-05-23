# frozen_string_literal: true

# Modify a new Rails app to become a Ros service
# NOTE: Dir.pwd returns dummy_path while destination_root returns the app path
def source_paths
  [user_path.join('templates'), core_path.join('templates'), internal_path.join('core'),
   core_path, internal_path] + Array(super)
end

def user_path
  Pathname.new(destination_root).join('../../../generators/core')
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
@profile = Profile.new(name, self, options.dup)

apply('gemspec.rb')
apply('gems.rb')
apply('postgres.rb')
apply('readme.rb')

gem 'ros-core', path: "#{@profile.ros_lib_path}/core"
