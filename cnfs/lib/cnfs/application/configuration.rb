# frozen_string_literal: true

require 'cnfs/plugin/configuration'

require 'active_support/inflector'

module Cnfs
  class Application
    class Configuration < Cnfs::Plugin::Configuration
      XDG_BASE = 'cnfs-cli'
      XDG_PROJECTS_BASE = 'cnfs-cli/projects'

      def after_initialize
        # Set defaults
        # self.dev = false
        # self.dry_run = false
        self.logging = :warn
        self.quiet = false

        # Default paths
        paths.segments = 'segments'
        # paths.data = 'data'
        # paths.tmp = 'tmp'
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

        # Disable loading of component if not in a valid project, e.g. cnfs new is being invoked
        #
        self.load_nodes = false unless project
      end

      # The prefix of ENV vars specified in config/application.rb
      def env_base() = 'CNFS_'

      # return XDG_BASE and the project_id so that each project's local files are isolated
      def xdg_name() = @xdg_name ||= "#{self.class::XDG_PROJECTS_BASE}/#{project_id}"

      def cli_cache_home() = xdg.cache_home.join(self.class::XDG_BASE)
    end
  end
end
