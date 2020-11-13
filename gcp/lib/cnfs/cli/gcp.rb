require "cnfs/cli/gcp/version"

module Cnfs
  module Cli
    module Gcp
      class << self
        def gem_root
          @gem_root ||= Pathname.new(__dir__).join('../../..')
        end

        def initialize
          puts "Initializing plugin gcp from #{gem_root}" if Cnfs.config.debug.positive?
          Cnfs.autoload_dirs += Cnfs.autoload_all(gem_root)
        end

        def on_project_initialize
        end

        # TODO: Copy in blueprints, etc
        def customize
        end
      end
    end
  end
end
