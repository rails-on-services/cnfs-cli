# frozen_string_literal: true

# Stdlibs
require 'fileutils'
require 'yaml'

# External dependencies
require 'active_support/concern'
require 'active_support/core_ext/enumerable'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/module/introspection'
require 'active_support/inflector'
require 'active_support/notifications'
require 'active_support/time'

# TODO: Move lockbox to core somewhere
require 'lockbox'
require 'thor'
require 'tty-logger'
# require 'xdg'
# require 'zeitwerk'

# Cnfs libs
require_relative 'cnfs/data_store'
require_relative 'cnfs/errors'
require_relative 'cnfs/loader'
require_relative 'cnfs/timer'
require_relative 'cnfs/version'

# Cnfs core extensions
require_relative 'ext/hash'
require_relative 'ext/open_struct'
require_relative 'ext/pathname'
require_relative 'ext/string'


module Cnfs
  class Error < StandardError; end

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
        Cnfs.config.logging = config.level = level
        config.level = level
      end
    end

    # TODO: Decide what to do with subscribers
    def x_reset
      subscribers.each { |sub| ActiveSupport::Notifications.unsubscribe(sub.pattern) }
    end

    # Record any ActiveRecord pubsub subsribers
    def subscribers() = @subscribers ||= []

    # TODO: Is this necessary?
    def with_profiling
      unless ENV['CNFS_PROF']
        yield
        return
      end

      require 'ruby-prof'
      RubyProf.start
      yield
      results = RubyProf.stop
      File.open("#{Dir.home}/cnfs-cli-prof.html", 'w+') { |file| RubyProf::GraphHtmlPrinter.new(results).print(file) }
    end
  end
end
