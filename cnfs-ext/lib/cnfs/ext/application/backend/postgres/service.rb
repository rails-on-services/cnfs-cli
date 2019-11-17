# frozen_string_literal: true

module Cnfs::Ext
  module Application::Backend
    class Postgres::Service < Cnfs::Core::Concerns::Generator

      def manifest
        template("#{orchestrator}.yml.erb", "#{values.path_for}/#{options.service}.yml")
      end

      private

      def a_path; __dir__ end
      def gem_root; Cnfs::Ext.gem_root end
    end
  end
end
