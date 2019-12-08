# frozen_string_literal: true

module Cnfs::Ext
  module Application::Backend
    class Localstack::Service < Cnfs::Core::Concerns::Generator

      def environment
        return unless values.environment
        create_file("#{values.path_for}/#{options.service}.env", "#{values.environment.to_env.join("\n")}\n")
        env_files.append("../#{options.service}/#{options.service}.env")
      end

      def manifest
        template("#{orchestrator}.yml.erb", "#{values.path_for}/#{options.service}.yml")
      end

      private

      def a_path; __dir__ end
      def gem_root; Cnfs::Ext.gem_root end
    end
  end
end
