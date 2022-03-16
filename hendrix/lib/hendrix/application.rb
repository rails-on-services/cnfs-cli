# frozen_string_literal: true

require_relative 'plugin'
require_relative 'application/configuration'

module Hendrix
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
      #   Hendrix.config.logging = config.level = level
      #   config.level = level
      # end
    end
  end

  class Application < Plugin
    class << self
      # https://github.com/rails/rails/blob/main/railties/lib/rails/application.rb#L68
      def inherited(base)
        super
        Hendrix.app_class = base
      end

      def gem_root() = APP_ROOT
    end

    def config() = @config ||= self.class.superclass::Configuration.new

    def name() = self.class.name.deconstantize.downcase

    # TODO: Test this wrt to the boot process and loading of config/application.rb
    # The prefix of ENV vars specified in config/application.rb
    config.before_initialize do |config|
      config.env_base = 'CNFS_' if config.env_base.empty?
    end

    # https://github.com/rails/rails/blob/main/railties/lib/rails/application.rb#L367
    def initialize!
      Extension.initialize! { Plugin.initialize! }
      self
    end
  end
end
