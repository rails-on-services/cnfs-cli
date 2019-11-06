# frozen_string_literal: true

module Cnfs::Core
  module Generator::Application::Backend::Rails
    class PlatformEnv < Thor::Group
      include Thor::Actions
      attr_accessor :values
      # add_runtime_options!
      # def self.a_path; File.dirname(__FILE__) end
      # jdef self.source_paths; [File.dirname(__FILE__)] end
      def self.source_paths
        [
          File.dirname(__FILE__).gsub(Cnfs::Ext.gem_root.join('lib/cnfs/core/generator').to_s,
                                      Cnfs::Ext.gem_root.join('lib/cnfs/core/templates').to_s)
        ]
      end

      def environment_file
        create_file("#{values.path_for}/platform.env", "#{values.environment.to_env.join("\n")}\n")
      end
    end
  end
end
