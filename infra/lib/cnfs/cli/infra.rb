# frozen_string_literal: true

require 'cnfs/cli/infra/version'

module Cnfs
  module Cli
    module Infra
      class << self
        def gem_root
          @gem_root ||= Pathname.new(__dir__).join('../../..')
        end

        def setup
          puts "Initializing plugin infra from #{gem_root}" if Cnfs.debug > 0
          # puts Cnfs.skip_schema
          # binding.pry # if Cnfs.debug > 1
          Cnfs.application.paths['db'].append(gem_root.join('db')) if Cnfs.application
          Cnfs.application.paths['app/views'].append(gem_root.join('app/views')) if Cnfs.application
          # Cnfs.autoload_dirs << gem_root.join('app/controllers')
          # Cnfs.autoload_dirs << gem_root.join('app/models')
          Cnfs.autoload_dirs += Cnfs.autoload_all(gem_root)
          Cnfs.controllers << { klass: 'TargetsController', title: 'infra', help: 'infra [SUBCOMMAND]', description: 'Manage target infrastructure: k8s clusters, storage, etc' }
        end
      end
    end
  end
end
