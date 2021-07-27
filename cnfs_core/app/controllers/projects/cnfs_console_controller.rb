# frozen_string_literal: true

require 'pry'

class Console < Pry::ClassCommand
  match 'commands'
  group 'cnfs'
  description 'List commands available in the current command set'

  def process(_command_set)
    if target_self.instance_of?(Projects::ConsoleController)
      puts "#{target_self.class.commands.join("\n")}\n\nreload!"
    else
      puts target_self.class.instance_methods(false).join("\n")
    end
  end
end

CnfsCommandSet = Pry::CommandSet.new
CnfsCommandSet.add_command(Console)
Pry.config.commands.import CnfsCommandSet

module Projects
  class CnfsConsoleController
    include ExecHelper

    def execute
      Cnfs.config.is_cli = true
      Pry.config.prompt = Pry::Prompt.new('cnfs', 'cnfs prompt', [__prompt])
      self.class.reload
      Pry.start(self)
    end

    class << self
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def reload
        commands.each do |command_set|
          define_method(command_set) do
            Pry.start("#{command_set}_controller".classify.safe_constantize.new(args, options))
            true
          end
        end

        shortcuts.each_pair do |key, klass|
          define_method(key) { klass } unless %w[p r].include?(key)
          define_method("#{key}a") { klass.all }
          define_method("#{key}f") { cache["#{key}f"] ||= klass.first }
          define_method("#{key}l") { cache["#{key}l"] ||= klass.last }
          define_method("#{key}p") { |*attributes| klass.pluck(*attributes) }
          define_method("#{key}fb") { |name| klass.find_by(name: name) }
        end
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize

      def shortcuts
        return {} unless defined?(ActiveRecord)

        shortcuts = model_shortcuts
        ActiveSupport::Notifications.instrument 'add_console_shortcuts.cnfs', { shortcuts: shortcuts }
        shortcuts
      end
    end

    def cache
      @cache ||= {}
    end

    def reset_cache
      @cache = nil
    end

    def reload!
      reset_cache
      Cnfs.reload
      self.class.reload
      true
    end

    def r
      reload!
    end

    def o
      options
    end

    def oa(opts = {})
      options.merge!(opts)
    end

    def od(key)
      @options = Thor::CoreExt::HashWithIndifferentAccess.new(options.except(key.to_s))
      options
    end

    def method_missing(method)
      puts "Invalid command '#{method}'"
    end
  end
end
