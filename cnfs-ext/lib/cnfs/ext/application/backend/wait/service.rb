# frozen_string_literal: true

module Cnfs::Ext
  module Application::Backend
    class Wait::Service < Cnfs::Core::Concerns::Generator

      def manifest
        template("#{orchestrator}.yml.erb", "#{values.path_for}/#{options.service}.yml")
      end

      private

      def depends_on
        values.settings.depends_on.map { |key| "- #{key}" }.join("\n      ")
      end

      def targets
        values.settings.depends_on.map { |key| "#{key}:#{dependency_ports[key.to_sym]}" }.join(',')
      end

      def dependency_ports
        {
          postgres: '5432',
          redis: '6379',
          fluentd: '24224',
          localstack: '4572'
        }
      end

      def a_path; __dir__ end
      def gem_root; Cnfs::Ext.gem_root end
    end
  end
end
