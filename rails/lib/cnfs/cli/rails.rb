# frozen_string_literal: true

require 'cnfs/cli/rails/version'

module Cnfs
  module Cli
    module Rails
      class << self
        def gem_root
          @gem_root ||= Pathname.new(__dir__).join('../../..')
        end

        def initialize
          puts "Initializing plugin rails from #{gem_root}" if Cnfs.config.debug.positive?
          # Cnfs.controllers << {
          #   extension_point: 'Services::NewController', extension: 'Rails::Services::NewController',
          #   # title: 'xrails', help: 'xrails [SUBCOMMAND]',
          #   # description: 'Add a CNFS service based on the Ruby on Rails Framework'
          # }
        end

        def on_project_initialize
          return unless Cnfs.project

          Cnfs.project.paths['config'].unshift(gem_root.join('config'))
          Cnfs.project.paths['app/views'].unshift(gem_root.join('app/views'))
        end

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
