# frozen_string_literal: true

module Primary
  class ConsoleController < ApplicationController
    cattr_reader :command_group, default: :service_runtime

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
          end
          TOPLEVEL_BINDING.eval('self').extend(self)
        end

        def shortcuts
          { a: Application, c: Context, d: Deployment, k: Key, n: Namespace, p: Provider, r: Resource, s: Service,
            t: Target, u: User }
        end
      end
    end

    def execute
      if context.service.nil?
        start_cnfs_console
        return
      elsif not context.service.respond_to?(:console_command)
        output.puts "#{context.service.name} does not implement the console command"
        return
      end

      # TODO: This is broken
      before_execute_on_target
      context.runtime.exec(context.service.name, context.service.console_command, true).run!
      # context.response.run!
    end

    def start_cnfs_console
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
      Pry.start # PrimaryController.new
    end
  end
end
