# frozen_string_literal: true

require 'hendrix/tune/configuration'

require 'active_support/inflector'

module Hendirx
  class Application
    class Configuration < Hendrix::Tune::Configuration
      XDG_BASE = 'cnfs-cli'
      XDG_PROJECTS_BASE = 'cnfs-cli/projects'

      # Override this method to provide defaults before the user configuration is parsed
      def after_initialize() = nil

      def root() = APP_ROOT

      # user-specific non-essential (cached) data
      def cache_home() = @cache_home ||= xdg.cache_home.join(xdg_name)

      # user-specific configuration files
      def config_home() = @config_home ||= xdg.config_home.join(xdg_name)

      # user-specific data files
      def data_home() = @data_home ||= xdg.data_home.join(xdg_name)

      def xdg_name() = name

      # https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
      def xdg() = @xdg ||= XDG::Environment.new

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
