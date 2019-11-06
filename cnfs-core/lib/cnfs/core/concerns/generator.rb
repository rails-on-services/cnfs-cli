# frozen_string_literal: true

module Cnfs::Core::Concerns
  module Generator
    attr_accessor :values

    def self.included(base)
      base.include(Thor::Actions)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # def source_paths; [user_path, internal_path] end
      # def user_path; Ros.root.join("#{a_path.gsub("#{Ros.gem_root}/lib/ros", 'lib/generators')}/templates") end
      # def internal_path; "#{a_path}/templates" end
      def a_source_paths
        path, = caller[0].partition(":")
        [
          File.dirname(path).gsub(Cnfs::Core.gem_root.join('lib/cnfs/core/generators').to_s,
                                  Cnfs::Core.gem_root.join('lib/cnfs/core/templates').to_s)
        ]
      end
    end
  end
end
