# frozen_string_literal: true

require 'pry'

module SolidSupport
  module ConsoleController
    extend ActiveSupport::Concern

    def execute # rubocop:disable Metrics/AbcSize
      self.class.hex
      SolidSupport.config.cli.mode = true
      SolidSupport.config.console = self
      Pry.config.prompt = Pry::Prompt.new('cnfs', 'cnfs prompt', [self.class.prompt])
      self.class.define_shortcuts if defined?(ActiveRecord) && ENV['HENDRIX_CLI_ENV'].eql?('development')
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

    class_methods do
      def hex
        # Get the MainCommand commands and create a console command for each
        module_parent::MainCommand.all_commands.keys.excluding(%w[help]).each do |cmd|
          main_command_class = module_parent::MainCommand
          Pry::Commands.block_command cmd, "Run #{cmd}" do |*args|
            # TODO: There is a bug here with passing args
            main_command_class.new.send(cmd, *args)
          end
        end
      end

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
