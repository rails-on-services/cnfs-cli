# frozen_string_literal: true

module Project
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
            define_method("#{key}f") { Project::ConsoleController::Commands.cache["#{key}f"] ||= klass.first }
            define_method("#{key}l") { Project::ConsoleController::Commands.cache["#{key}l"] ||= klass.last }
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
      require 'pry'
      Pry::Commands.block_command 'r', 'Reload', keep_retval: true do |*_args|
        Project::ConsoleController::Commands.reset_cache
        Cnfs.reload
      end
      # TODO: Alias 'r' above to this command
      Pry::Commands.block_command 'reload!', 'Reload', keep_retval: true do |*_args|
        Project::ConsoleController::Commands.reset_cache
        Cnfs.reload
      end
      Project::ConsoleController::Commands.load
      Pry.start(self, prompt: proc { |_obj, _nest_level, _| 'cnfs> ' })
    end
  end
end
