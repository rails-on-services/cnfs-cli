# frozen_string_literal: true

require 'cnfs/cli/backend/version'

module Cnfs
  module Cli
    module Backend
      class << self
        def gem_root
          @gem_root ||= Pathname.new(__dir__).join('../../..')
        end

        def setup
          puts "Initializing plugin backend from #{gem_root}" if Cnfs.debug > 0
          # puts Cnfs.skip_schema
          Cnfs.application.paths['db'].append(gem_root.join('db')) if Cnfs.application
          Cnfs.application.paths['app/views'].append(gem_root.join('app/views')) if Cnfs.application
          Cnfs.autoload_dirs += Cnfs.autoload_all(gem_root)
          Cnfs.controllers << { klass: 'BackendController', title: 'backend', help: 'backend [SUBCOMMAND]', description: 'Manage backend projects' }
        end
      end
    end
  end
end
