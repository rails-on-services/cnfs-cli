# frozen_string_literal: true

module Primary
  class CommandController < ApplicationController
    def execute
      # each_target do
      #   before_execute_on_target
      #   execute_on_target
      # end
    end

    # def execute_on_target
    #   runtime.run(args.command.join(' '), pty: true).run!
    # end
  end
end
