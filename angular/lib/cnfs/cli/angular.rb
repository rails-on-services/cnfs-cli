# frozen_string_literal: true

require 'cnfs/cli/angular/version'

module Cnfs
  module Cli
    module Angular
      class << self
        def gem_root
          @gem_root ||= Pathname.new(__dir__).join('../../..')
        end

        def initialize
          Cnfs.logger.info "Initializing plugin angular from #{gem_root}"
        end

        def on_project_initialize; end

        def customize
          src = gem_root.join('app/generators/rails')
          dest = Cnfs.paths.lib.join('generators/rails')
          FileUtils.rm_rf(dest)
          FileUtils.mkdir_p(dest)
          %w[service lib].each do |node|
            FileUtils.cp_r(src.join(node), dest)
          end
        end
      end
    end
  end
end
