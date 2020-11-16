# frozen_string_literal: true

require 'cnfs/cli/cnfs_backend/version'

module Cnfs
  module Cli
    module CnfsBackend
      class << self
        def gem_root
          @gem_root ||= Pathname.new(__dir__).join('../../..')
        end

        def initialize
          Cnfs.logger.info "Initializing plugin cnfs_backend from #{gem_root}"
        end

        def on_project_initialize
          return unless Cnfs.project

          Cnfs.project.paths['config'].unshift(gem_root.join('config'))
          Cnfs.project.paths['app/views'].unshift(gem_root.join('app/views'))
        end

        def customize
          src = gem_root.join('app/generators/cnfs_backend')
          dest = Cnfs.paths.lib.join('generators/cnfs_backend')
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
