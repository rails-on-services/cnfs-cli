# frozen_string_literal: true

module Cnfs::Core
  module Generators::Application::Backend
    class ComposeEnv < Thor::Group
      include Cnfs::Core::Concerns::Generator

      def self.source_paths; a_source_paths end

      def setup
        @values = options[:values]
        empty_directory(values.path_for)
        template('compose.env', compose_file)
      end

      private

      # NOTE: These might be needed for the CLI to link to files
      def compose_file; @compose_file ||= "#{compose_dir}/compose.env" end
      # def compose_dir; "#{Ros.root}/tmp/runtime/#{Ros.env}/#{current_feature_set}" end
      def compose_dir; "#{values.path_for(:runtime)}/compose" end
      # def compose_project_name; "#{Stack.name}_#{current_feature_set}" end
      def compose_project_name; "#{values.config.name}-#{values.env_name}" end
    end
  end
end
