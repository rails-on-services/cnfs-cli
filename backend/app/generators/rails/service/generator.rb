# frozen_string_literal: true
#
# Modify a new Rails application or plugin (engine) into a CNFS service
def cnfs
  @cnfs
end

def source_paths
  [views_path, views_path.join('templates'), lib_path, lib_path.join('templates'),
    core_path, core_path.join('templates')] + Array(super)
end

def views_path
  internal_path.join(ENV['CNFS_SERVICE_TYPE'])
end

def lib_path
  internal_path.join('lib')
end

def core_path
  internal_path.join('../lib')
end

def internal_path
  Pathname.new(__dir__)
end

require 'pry'
# require "#{core_path}/profile"

cnfs_envs = ENV.select{ |env| env.start_with? 'CNFS_' }.transform_keys!{ |key| key.delete_prefix('CNFS_').downcase }
@cnfs = Class.new do
  attr_accessor :options
  cnfs_envs.each_key { |key| attr_accessor key }
  def routes_file; "#{app_dir}/config/routes.rb" end
  def username; `git config user.name`.chomp end
  def email; `git config user.email`.chomp end
  def is_engine?; (options.full || options.mountable) end
  def module_name; service_name.classify end
  def config_file; is_engine? ? "lib/#{service_name.gsub('-', '/')}.rb" : 'config/application.rb' end
  # TODO: this is used in tenant template for service plugins
  def module_string; is_engine? ? module_name : 'Ros' end
end.new
cnfs.options = options
cnfs_envs.each { |key, value| @cnfs.send("#{key}=", value) }
@lib_path = '../..'

# @profile = Profile.new(@service_name, self, options.dup)

work_dir = cnfs.service_type.eql?('plugin') ? '../..' : '.'
Dir.chdir(work_dir) do
  apply("#{internal_path}/#{cnfs.service_type}_generator.rb")
end
