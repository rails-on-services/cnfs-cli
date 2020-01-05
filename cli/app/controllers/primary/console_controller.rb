# frozen_string_literal: true

module Primary
  class ConsoleController < ApplicationController
    module Commands
      class << self
        def cache; @cache ||= {} end

        def reset_cache; @cache = nil end

        def load
          shortcuts.each_pair do |key, klass|
            define_method("#{key}a") { klass.all }
            define_method("#{key}f") { Primary::ConsoleController::Commands.cache["#{key}f"] ||= klass.first }
            define_method("#{key}l") { Primary::ConsoleController::Commands.cache["#{key}l"] ||= klass.last }
          end
          TOPLEVEL_BINDING.eval('self').extend(self)
        end

        def shortcuts
          { d: Deployment, a: Application, t: Target, r: Resource, s: Service, p: Provider }
        end
      end
    end

    def execute
      if not args.service_names
        start_cnfs_console
        return
      end

      each_target do |target|
        output.puts "TODO: execute a console on the #{args.service_names} remote service"
      end
    end

    def limits
      return {} unless args.service_name
      { deployments: 1, services: 1 }
    end

    def start_cnfs_console
      Pry::Commands.block_command 'r', 'Reload', keep_retval: true do |*args|
        Primary::ConsoleController::Commands.reset_cache
        Cnfs.reload
      end
      # TODO: Alias 'r' above to this command
      Pry::Commands.block_command 'reload!', 'Reload', keep_retval: true do |*args|
        Primary::ConsoleController::Commands.reset_cache
        Cnfs.reload
      end
      Primary::ConsoleController::Commands.load
      Pry.start PrimaryController.new
    end
  end
end
