# frozen_string_literal: true

require_relative 'tune'
require_relative 'application/configuration'

module Hendrix
  class << self
    attr_writer :logger
    attr_accessor :app_class, :cli_mode

    def config() = application.config

    def application() = @application ||= app_class.new

    def gem_root() = @gem_root ||= Pathname.new(__dir__).join('..')

    # TODO: Multiple loggers
    def logger() = @logger ||= set_logger

    def set_logger
      default_level = (config.logging || 'warn').to_sym
      level = ::TTY::Logger::LOG_TYPES.keys.include?(default_level) ? default_level : :warn
      ::TTY::Logger.new do |config|
        Hendrix.config.logging = config.level = level
        config.level = level
      end
    end
  end

  class Application < Tune

    def config() = self.class.config

    def name() = self.class.name.deconstantize.downcase

    class << self
      def config() = @config ||= Configuration.new
      def config()
        # binding.pry
        @config ||= Hendrix::Application::Configuration.new
      end

      # https://github.com/rails/rails/blob/main/railties/lib/rails/application.rb#L68
      def inherited(base)
        super
        Hendrix.app_class = base
      end

      def gem_root() = APP_ROOT
    end

    # https://github.com/rails/rails/blob/main/railties/lib/rails/application.rb#L367
    def initialize!
      config.after_user_config
      self
    end

    config.after_initialize do |config|
      binding.pry
      # Set defaults
      # self.dev = false
      # self.dry_run = false
      config.logging = :warn
      config.quiet = false

      # Default paths
      # paths.data = 'data'
      # paths.tmp = 'tmp'
    end
  end
end
