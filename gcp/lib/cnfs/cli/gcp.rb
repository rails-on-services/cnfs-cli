# frozen_string_literal: true

require 'cnfs/cli/gcp/version'

module Cnfs
  module Cli
    module Gcp
      class << self
        def gem_root
          @gem_root ||= Pathname.new(__dir__).join('../../..')
        end

        def initialize
          Cnfs.logger.info "Initializing plugin gcp from #{gem_root}"
        end

        def on_project_initialize; end

        # TODO: Copy in blueprints, etc
        def customize; end
      end
    end
  end
end
