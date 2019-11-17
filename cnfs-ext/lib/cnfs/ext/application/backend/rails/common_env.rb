# frozen_string_literal: true

module Cnfs::Ext
  module Application::Backend
    class Rails::CommonEnv < Cnfs::Core::Concerns::Generator

      def setup
        @values = options[:values]
      end

      def environment_file
        # binding.pry
        create_file("#{values.path_for}/platform.env", "#{values.environment.to_env.join("\n")}\n")
      end

      private

      def a_path; __dir__ end
      def gem_root; Cnfs::Ext.gem_root end
    end
  end
end
