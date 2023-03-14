# frozen_string_literal: true

require_relative 'plugin'
require_relative 'application/configuration'

module SolidSupport
  class << self
    attr_writer :logger
    attr_accessor :app_class, :cli_mode

    def config() = application.config

    def application() = @application ||= app_class.instance

    def gem_root() = @gem_root ||= Pathname.new(__dir__).join('..')

    # TODO: Multiple loggers
    def logger() = @logger ||= set_logger

    def set_logger
      default_level = (config.logging || 'warn').to_sym
      ActiveSupport::Logger.new($stdout)
      # level = ::TTY::Logger::LOG_TYPES.key?(default_level) ? default_level : :warn
      # ::TTY::Logger.new do |config|
      #   SolidSuport.config.logging = config.level = level
      #   config.level = level
      # end
    end
  end

  class Application < Plugin
    class << self
      # https://github.com/rails/rails/blob/main/railties/lib/rails/application.rb#L68
      def inherited(base)
        super
        set_config(base)
        module_parent.app_class = base
      end

      # Extensions that have a default config are merged into the application's config
      # so the user can modify those values
      def set_config(base)
        module_parent.extensions.values.each do |extension|
          next unless extension.module_parent.respond_to?(:config)

          extension_name = extension.module_parent.name.underscore.to_sym
          extension_config = extension.module_parent.config
          base.config.send(extension_name).merge!(extension_config)
        end
      end

      def gem_root() = APP_ROOT
    end

    def config() = @config ||= self.class.superclass::Configuration.new

    def name() = self.class.name.deconstantize.downcase

    # TODO: Test this wrt to the boot process and loading of config/application.rb
    # The prefix of ENV vars specified in config/application.rb
    config.before_initialize do |config|
      # config.view_options ||= { help_color: :brown }
      # config.env_base = 'CNFS_' if config.env_base.empty?
    end

    # https://github.com/rails/rails/blob/main/railties/lib/rails/application.rb#L367
    def initialize!
      Extension.initialize! { Plugin.initialize! }
      self
    end
  end
end
