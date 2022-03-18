# frozen_string_literal: true

# External dependencies
require 'active_support/concern'
require 'active_support/core_ext/enumerable'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/module/introspection'
require 'active_support/inflector'
require 'active_support/notifications'
require 'active_support/time'
# require 'tty-tree'

require_relative 'ext/hash'
require_relative 'ext/open_struct'
require_relative 'ext/string'

require_relative 'solid_support/interpolation'

# Stdlibs
require 'fileutils'
require 'yaml'


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
