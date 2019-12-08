# frozen_string_literal: true

module Cnfs::Ext
  module Application::Backend
    class Nginx::Service < Cnfs::Core::Concerns::Generator

      def manifest
        binding.pry
        template("#{orchestrator}.yml.erb", "#{values.path_for}/#{options.service}.yml")
      end

      def nginx_conf
        # return unless orchestrator.eql?(:compose) # and behavior.eql?(:invoke)
        # remove_file("#{values.path_for}/nginx.conf")
        template('nginx.conf.erb', "#{values.path_for}/nginx.conf")
      end

      private

      # def nginx_services; %w[hello] end
      def nginx_services; values.services end

      def a_path; __dir__ end
      def gem_root; Cnfs::Ext.gem_root end
    end
  end
end
