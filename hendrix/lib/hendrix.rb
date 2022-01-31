# frozen_string_literal: true

# Stdlibs
require 'fileutils'
require 'yaml'

# TODO: Isn't this already required by the Application? or what about when new?
# Test and make a note here if needed for new command
require 'bundler/setup'
require 'solid-support'

# TODO: Move lockbox to core somewhere
# require 'lockbox'
require 'thor'
require 'tty-logger'
# require 'xdg'
# require 'zeitwerk'

# Hendrix libs
require_relative 'hendrix/application'
require_relative 'hendrix/errors'
require_relative 'hendrix/loader'
require_relative 'hendrix/timer'
require_relative 'hendrix/version'
# binding.pry

require 'solid-record' unless defined? APP_ROOT

module Hendrix
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
