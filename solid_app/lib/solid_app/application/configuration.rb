# frozen_string_literal: true

require 'xdg'
require 'active_support/inflector'

require_relative '../plugin/configuration'

module SolidApp
  class Application < Plugin
    class Configuration < SolidApp::Plugin::Configuration
      def root() = APP_ROOT

      # user-specific non-essential (cached) data
      def cache_home() = @cache_home ||= xdg.cache_home.join(xdg_name)

      # user-specific configuration files
      def config_home() = @config_home ||= xdg.config_home.join(xdg_name)

      # user-specific data files
      def data_home() = @data_home ||= xdg.data_home.join(xdg_name)

      # return a unique path using the project_id so that each project's local files are isolated
      def xdg_name() = @xdg_name ||= "#{xdg_base}/#{xdg_projects_base}/#{project_id}"

      # Overridde in a subclass to set a different value
      def xdg_projects_base() = 'projects'

      def xdg_base() = self.class.module_parent.module_parent.to_s.downcase

      def cli_cache_home() = xdg.cache_home.join(xdg_base)

      # https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
      def xdg() = @xdg ||= XDG::Environment.new
    end
  end
end
