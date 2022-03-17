# frozen_string_literal: true

# External dependencies
require 'active_support/concern'
require 'active_support/core_ext/enumerable'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/module/introspection'
require 'active_support/inflector'
require 'active_support/notifications'
require 'active_support/time'
require 'tty-tree'

require_relative 'ext/hash'
require_relative 'ext/open_struct'
require_relative 'ext/string'

require_relative 'solid_support/interpolation'

require_relative 'solid_support/models/command'
require_relative 'solid_support/models/command_queue'
require_relative 'solid_support/models/download'
require_relative 'solid_support/models/extendable'
require_relative 'solid_support/models/git'

# Stdlibs
require 'fileutils'
require 'yaml'

# TODO: Isn't this already required by the Application? or what about when new?
# Test and make a note here if needed for new command
require 'bundler/setup'
require 'solid_support'

require 'thor'
# require 'tty-logger'
# require 'xdg'
# require 'zeitwerk'

# application libs
require_relative 'solid_support/application'
require_relative 'solid_support/application_command'
require_relative 'solid_support/application_controller'
require_relative 'solid_support/application_generator'
require_relative 'solid_support/console_controller'
require_relative 'solid_support/errors'
require_relative 'solid_support/loader'
require_relative 'solid_support/timer'
require_relative 'solid_support/version'
# binding.pry

module SolidSupport
  class Error < StandardError; end

  class << self
    # TODO: Decide what to do with subscribers
    def x_reset
      subscribers.each { |sub| ActiveSupport::Notifications.unsubscribe(sub.pattern) }
    end

    # Record any ActiveRecord pubsub subsribers
    def subscribers() = @subscribers ||= []

    # TODO: Is this necessary?
    def with_profiling
      unless ENV['HENDRIX_PROF']
        yield
        return
      end

      require 'ruby-prof'
      RubyProf.start
      yield
      results = RubyProf.stop
      File.open("#{Dir.home}/hendrix-prof.html", 'w+') { |file| RubyProf::GraphHtmlPrinter.new(results).print(file) }
    end
  end
end
