# frozen_string_literal: true

module Hendrix
  module New; end
  module Concerns; end
  class HendrixPlugin < ::Hendrix::Tune
    class << self
      def before_loader_setup(loader) = loader.ignore(loader_ignore_files)

      def loader_ignore_files
        [
          gem_root.join('app/generators/cnfs/new/extension'),
          gem_root.join('app/generators/cnfs/new/plugin'),
          gem_root.join('app/generators/cnfs/new/project')
        ]
      end

      def gem_root() = @gem_root ||= Pathname.new(__dir__).join('../..')
    end
  end
end
