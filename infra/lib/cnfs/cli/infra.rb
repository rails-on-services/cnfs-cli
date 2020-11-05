# frozen_string_literal: true

require 'cnfs/cli/infra/version'

module Cnfs
  module Cli
    module Infra
      class << self
        def gem_root
          @gem_root ||= Pathname.new(__dir__).join('../../..')
        end

        def initialize
          puts "Initializing plugin infra from #{gem_root}" if Cnfs.config.debug.positive?
          Cnfs.autoload_dirs += Cnfs.autoload_all(gem_root)
        end

        def on_project_initialize
          return unless Cnfs.project

          Cnfs.project.paths['config'].append(gem_root.join('config'))
          Cnfs.project.paths['app/views'].append(gem_root.join('app/views'))
          # Cnfs.controllers << { klass: 'TargetsController', title: 'infra', help: 'infra [SUBCOMMAND]',
          #                       description: 'Manage target infrastructure: k8s clusters, storage, etc' }
        end

        # TODO: Copy in blueprints, etc
        def customize
        end
      end
    end
  end
end
