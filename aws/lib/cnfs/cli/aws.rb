# frozen_string_literal: true

require 'cnfs/cli/aws/version'

module Cnfs
  module Cli
    module Aws
      class << self
        def gem_root
          @gem_root ||= Pathname.new(__dir__).join('../../..')
        end

        def initialize
          puts "Initializing plugin aws from #{gem_root}" if Cnfs.config.debug.positive?
        end

        def on_project_initialize
          return unless Cnfs.project

          Cnfs.project.paths['config'].append(gem_root.join('config'))
          Cnfs.project.paths['app/views'].append(gem_root.join('app/views'))
        end

        # TODO: Copy in blueprints, etc
        def customize; end
      end
    end
  end
end
