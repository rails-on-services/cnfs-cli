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
          end
          TOPLEVEL_BINDING.eval('self').extend(self)
        end

        def shortcuts
          { a: Application, c: Context, d: Deployment, k: Key, p: Provider, r: Resource, s: Service,
            t: Target, u: User }
        end
      end
    end

    def execute
      if args.service_names.empty?
        start_cnfs_console
        return
      end

      each_target do |_target|
        execute_on_target
      end
    end

    def execute_on_target
      unless request.services.last.respond_to?(:console_command)
        output.puts "#{request.services.last.name} does not implement the console command"
        return
      end

      before_execute_on_target
      runtime.exec(request.last_service_name, request.services.last.console_command, true)
      response.run!
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
