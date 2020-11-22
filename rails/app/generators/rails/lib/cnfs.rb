# frozen_string_literal: true

require 'pry'

def cnfs; @cnfs end

prefix = 'CNFS_'
cnfs_envs = ENV.select { |env| env.start_with?(prefix) }.transform_keys! { |key| key.delete_prefix(prefix).downcase }
@cnfs = Thor::CoreExt::HashWithIndifferentAccess.new(cnfs_envs)

# Merge in values used in the next merge
cnfs.merge!(
  is_engine: (options.full || options.mountable),
  module_name: cnfs.name.classify
)

# Final merge
cnfs.merge!(
  # TODO: this is used in tenant template for service plugins
  module_string: cnfs.is_engine ? cnfs.module_name : 'Ros',
  config_file: cnfs.is_engine ? "lib/#{cnfs.name.gsub('-', '/')}.rb" : 'config/application.rb',
  routes_file: "#{cnfs.app_dir}/config/routes.rb",
  email: `git config user.email`.chomp,
  username: `git config user.name`.chomp
)
