# frozen_string_literal: true

class ConsoleController < Cnfs::Command
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
    Pry.start
  end
end
