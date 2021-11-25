# frozen_string_literal: true

require 'active_support/inflector'

module CnfsCli
  class Config < Cnfs::Config
    def after_initialize
      # Set defaults
      self.dev = false
      self.dry_run = false
      self.logging = :warn
      self.quiet = false

      # Default paths
      paths.data = 'data'
      paths.tmp = 'tmp'
      paths.src = 'src'
    end

    def after_user_config
      # Transform paths from a string to an absolute path
      paths.transform_values! { |path| path.is_a?(Pathname) ? path : root.join(path) }

      # Set values for component selection based on any user defined ENVs
      segments.each do |key, values|
        env_key = "#{env_base}#{values[:env] || key}".upcase
        values[:env_value] = ENV[env_key]
      end

      # Set Command Options
      self.command_options = segments.dup.transform_values! do |opt|
        { desc: opt[:desc], aliases: opt[:aliases], type: :string }
      end

      # Disable loading of component if not in a valid project, i.e. cnfs new is being invoked
      self.load_nodes = false unless project
    end

    # If not in a valid project, i.e. cnfs new, then return the base path otherwise add the name to the path
    def xdg_name() = project ? "#{xdg_base}/#{project_id}" : xdg_base

    # The file that is present in the root of the project that indicates it is a cnfs-cli project
    def root_file_id() = '.cnfs'

    # The prefix of ENV vars specified in config/application.rb
    def env_base() = 'CNFS_'

    def xdg_base() = 'cnfs-cli'
  end
end
