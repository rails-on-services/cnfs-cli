# frozen_string_literal: true

require 'pry'

def cnfs
  @cnfs
end

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

cnfs.options = Hash[options]
cnfs_envs.each { |key, value| @cnfs.send("#{key}=", value) }
@lib_path = '../..'
