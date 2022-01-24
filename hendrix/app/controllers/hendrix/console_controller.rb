# frozen_string_literal: true

require 'pry'

# Get the commands defined on ApplicationController and create a CLI command for each
# Hendrix::ApplicationController.all_commands.keys.excluding(%w[help]).each do |cmd|
MainCommand.all_commands.keys.excluding(%w[help]).each do |cmd|
  Pry::Commands.block_command cmd, "Run #{cmd}" do |*args|
    # Hendrix::ApplicationController.new.send(cmd, *args)
    MainCommand.new.send(cmd, *args)
  end
end if defined? MainCommand

module Hendrix
  class ConsoleController < ApplicationController
    # include Hendrix::Concerns::ExecController
    def execute
      Hendrix.config.cli.mode = true
      Hendrix.config.console = self
      Pry.config.prompt = Pry::Prompt.new('cnfs', 'cnfs prompt', [self.class.prompt])
      self.class.define_shortcuts if defined?(ActiveRecord) && ENV['CNFS_CLI_ENV'].eql?('development')
      Pry.start(self)
    end

    # Reload all classes, remove and cached objects and re-define the shortcuts as classes have reloaded
    def reload!
      reset_cache
      Hendrix.reload
      self.class.define_shortcuts
      true
    end

    def reset_cache() = @cache = nil

    def cache() = @cache ||= {}

    def method_missing(method) = puts("Invalid command '#{method}'")

    # https://www.rubydoc.info/gems/rubocop/RuboCop/Cop/Style/MissingRespondToMissing
    def respond_to_missing?(method_name, *args)
      puts "missing: #{method_name}"
      method_name == :bark || super
    end

    class << self
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def define_shortcuts
        shortcuts.each_pair do |key, klass|
          define_method("#{key}a") { klass.all }
          define_method("#{key}c") { |**attributes| klass.create(attributes) }
          define_method("#{key}f") { cache["#{key}f"] ||= klass.first }
          define_method("#{key}fi") { |id| klass.find(id) }
          define_method("#{key}fn") { |name| klass.find_by(name: name) }
          define_method("#{key}k") { klass }
          define_method("#{key}l") { cache["#{key}l"] ||= klass.last }
          define_method("#{key}p") { |*attributes| klass.pluck(*attributes) }
          define_method("#{key}w") { |**attributes| klass.where(attributes) }
        end
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize

      def shortcuts
        these_shortcuts = {}
        ActiveSupport::Notifications.instrument 'add_console_shortcuts.cnfs', { shortcuts: these_shortcuts }
        these_shortcuts
      end

      def prompt
        proc do |obj, _nest_level, _|
          klass = obj.class.name.demodulize.delete_suffix('Controller').underscore
          label = klass.eql?('console') ? '' : " (#{obj.class.name})"
          "#{label}> "
        end
      end
    end
  end
end
