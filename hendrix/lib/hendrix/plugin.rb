# frozen_string_literal: true

module Hendrix
  module New; end
  module Concerns; end

  class Plugin < SolidSupport::Plugin
    class << self
      def before_loader_setup(loader) = loader.ignore(loader_ignore_files)

      def loader_ignore_files
        [
          gem_root.join('app/generators/hendrix/project/extension'),
          gem_root.join('app/generators/hendrix/project/plugin'),
          gem_root.join('app/generators/hendrix/project/application')
        ]
      end

      def gem_root() = @gem_root ||= Pathname.new(__dir__).join('../..')
    end

    config.after_initialize do |config|
      #   binding.pry
      #   # Set defaults
      #   # self.dev = false
      #   # self.dry_run = false
      config.logging = :fatal
      #   config.quiet = false

      #   # Default paths
      #   # paths.data = 'data'
      #   # paths.tmp = 'tmp'
    end
  end
end
