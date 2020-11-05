# frozen_string_literal: true

module Primary
  class ConsoleController < ApplicationController
    module Commands
      class << self
        def cache
          @cache ||= {}
        end

        def reset_cache
          @cache = nil
        end

        def load
          shortcuts.each_pair do |key, klass|
            define_method("#{key}a") { klass.all }
            define_method("#{key}f") { Primary::ConsoleController::Commands.cache["#{key}f"] ||= klass.first }
            define_method("#{key}l") { Primary::ConsoleController::Commands.cache["#{key}l"] ||= klass.last }
            define_method("#{key}fb") { |name| klass.find_by(name: name) }
          end
          TOPLEVEL_BINDING.eval('self').extend(self)
        end

        def shortcuts
          { b: Blueprint, e: Target, k: Key, n: Namespace, p: Provider, r: Resource, s: Service, u: User }
        end
      end
    end

    def execute
      if application.service.nil?
        start_cnfs_console
      elsif !application.service.respond_to?(:console_command)
        raise Cnfs::Error, "#{application.service.name} does not implement the console command"
      else
        application.runtime.exec(application.service, application.service.console_command, true).run!
      end
    end

    def start_cnfs_console
      require 'pry'
      Pry::Commands.block_command 'r', 'Reload', keep_retval: true do |*_args|
        Primary::ConsoleController::Commands.reset_cache
        Cnfs.reload
      end
      # TODO: Alias 'r' above to this command
      Pry::Commands.block_command 'reload!', 'Reload', keep_retval: true do |*_args|
        Primary::ConsoleController::Commands.reset_cache
        Cnfs.reload
      end
      Primary::ConsoleController::Commands.load
      Pry.start(self, prompt: proc { |obj, nest_level, _| "cnfs> " })
    end
  end
end
