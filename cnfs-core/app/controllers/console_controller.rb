# frozen_string_literal: true

class ConsoleController < Cnfs::Command
  def self.cache; @cache ||= {} end

  def self.reset_cache; @cache = nil end

  module Commands
    class << self
      def load
        shortcuts.each_pair do |key, klass|
          define_method("#{key}a") { klass.all }
          define_method("#{key}f") { ConsoleController.cache["#{key}f"] ||= klass.first }
          define_method("#{key}l") { ConsoleController.cache["#{key}l"] ||= klass.last }
        end
        TOPLEVEL_BINDING.eval('self').extend(self)
      end

      def shortcuts
        { d: Deployment, a: Application, t: Target, r: Resource, s: Service, p: Provider }
      end
    end
  end

  # def initialize(options)
  #   @options = options
  # end

  def execute(input: $stdin, output: $stdout)
    require 'pry'
    Pry::Commands.block_command 'r', 'Reload', keep_retval: true do |*args|
      ConsoleController.reset_cache
      Cnfs::Core.reload
    end
    # TODO: Alias 'r' above to this command
    Pry::Commands.block_command 'reload!', 'Reload', keep_retval: true do |*args|
      ConsoleController.reset_cache
      Cnfs::Core.reload
    end
    ConsoleController::Commands.load
    Pry.start
  end
end
