# frozen_string_literal: true

module Cnfs::Ext
  module Application::Backend
    class Compose::Env < Cnfs::Core::Concerns::Generator

      def setup
        # binding.pry
        # @values = options[:values]
        # empty_directory(values.path_for)
        template('env', options.compose_file)
      end

      private

      def a_path; __dir__ end
      def gem_root; Cnfs::Ext.gem_root end

      # NOTE: These might be needed for the CLI to link to files
      # def compose_file; @compose_file ||= "#{compose_dir}/compose.env" end
      # # def compose_dir; "#{Ros.root}/tmp/runtime/#{Ros.env}/#{current_feature_set}" end
      # def compose_dir; "#{values.path_for(:runtime)}/compose" end
      # # def compose_project_name; "#{Stack.name}_#{current_feature_set}" end
      # def compose_project_name; "#{values.config.name}-#{values.env_name}" end
    end
  end
end
