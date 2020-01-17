# frozen_string_literal: true

require 'cnfs/cli/cloud/version'

module Cnfs
  module Cli
    module Cloud
      class << self
        def gem_root; @gem_root ||= Pathname.new(__dir__).join('../../..') end

        def setup
          puts "Initializing plugin cloud from #{gem_root}" if Cnfs.debug > 0
          # puts Cnfs.skip_schema
          # binding.pry # if Cnfs.debug > 1
          Cnfs.config_dirs.unshift(gem_root.join('config'))
          # Cnfs.autoload_dirs << gem_root.join('app/controllers')
          # Cnfs.autoload_dirs << gem_root.join('app/models')
          Cnfs.autoload_dirs += Cnfs.autoload_all(gem_root)
          Cnfs.controllers << { klass: 'TargetsController', title: 'target', help: 'target [SUBCOMMAND]', description: 'Manage targets' }
        end
      end
    end
  end
end
