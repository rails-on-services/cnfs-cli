# frozen_string_literal: true

class ConsoleController < Cnfs::Command
  module Commands
    class << self
      def load
        define_method(:dd) { Deployment.find_by(name: :default) }
        { a: Application, d: Deployment, t: Target }.each_pair do |key, klass|
          define_method("#{key}a") { klass.all }
          define_method("#{key}f") { klass.first }
          define_method("#{key}l") { klass.last }
        end
        TOPLEVEL_BINDING.eval('self').extend(self)
      end
    end
  end

  def initialize(options)
    @options = options
  end

  def execute(input: $stdin, output: $stdout)
    require 'pry'
    Pry::Commands.block_command 'r', 'Reload', keep_retval: true do |*args|
      Cnfs::Core.reload
    end
    # TODO: Alias 'r' above to this command
    Pry::Commands.block_command 'reload!', 'Reload', keep_retval: true do |*args|
      Cnfs::Core.reload
    end
    ConsoleController::Commands.load
    Pry.start
  end
end
