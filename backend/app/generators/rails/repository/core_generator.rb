# frozen_string_literal: true
#
# Modify a new Rails plugin into the CNFS repository's core gem

def source_paths
  [views_path, views_path.join('templates'), lib_path, lib_path.join('templates')] + Array(super)
end

def views_path
  internal_path.join('core')
end

def lib_path
  internal_path.join('../lib')
end

def internal_path
  Pathname.new(__dir__)
end

require "#{lib_path}/profile"
@service_name = @name
@profile = Profile.new(@service_name, self, options.dup)

require 'pry'
binding.pry

apply('gemspec.rb')
apply('gems.rb')
apply('postgres.rb')
apply('readme.rb')

gem 'ros-core', path: "#{@profile.ros_lib_path}/core"