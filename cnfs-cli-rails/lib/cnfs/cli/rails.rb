# frozen_string_literal: true

require 'cnfs/cli/rails/version'

module Cnfs
  module Cli
    module Rails
      class << self
        def gem_root
          @gem_root ||= Pathname.new(__dir__).join('../../..')
        end

        def setup
          puts "Initializing plugin rails from #{gem_root}" if Cnfs.debug > 0
          # puts Cnfs.skip_schema
          Cnfs.config_dirs.unshift(gem_root.join('config'))
          Cnfs.autoload_dirs += Cnfs.autoload_all(gem_root)
          Cnfs.controllers << { klass: 'RailsController', title: 'rails', help: 'rails [SUBCOMMAND]', description: 'Manage rails projects' }
        end
      end
    end
  end
end
