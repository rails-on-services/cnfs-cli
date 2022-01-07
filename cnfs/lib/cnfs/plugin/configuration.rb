# frozen_string_literal: true

require 'xdg'
require 'active_support/ordered_options'

require 'cnfs/extension/configuration'

module Cnfs
  class Plugin
    class Configuration < Cnfs::Extension::Configuration
      def initialize(**options)
        @configurations = options
        after_initialize
      end

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

      # Reused from railties/lib/rails/application/configuration.rb
      def method_missing(method, *args)
        return if %i[after_initialize after_user_config].include?(method)

        if method.end_with?('=')
          @configurations[:"#{method[0..-2]}"] = args.first
        else
          @configurations.fetch(method) do
            @configurations[method] = ActiveSupport::OrderedOptions.new
          end
        end
      end

      def respond_to_missing?(_symbol, *) = true
    end
  end
end
