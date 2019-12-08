# frozen_string_literal: true

module Cnfs::Ext
  module Application::Backend
    class Fluentd::Service < Cnfs::Core::Concerns::Generator

      def manifest
        template("#{orchestrator}.yml.erb", "#{values.path_for}/#{options.service}.yml")
      end

      def create_log_dir
        return unless orchestrator.eql?(:compose) and behavior.eql?(:invoke)
        empty_directory(values.path_for(:runtime))
        FileUtils.chmod('+w', values.path_for(:runtime))
      end

      private

      def orchestrator; options.orchestrator end

      def a_path; __dir__ end
      def gem_root; Cnfs::Ext.gem_root end
    end
  end
end
