# frozen_string_literal: true

module Primary
  class BuildController < ApplicationController
    def execute
      each_target do |target|
        # before_execute_on_target
        execute_on_target
      end
      if errors.size.positive?
        publish_results
        Kernel.exit(errors.size)
        # TODO: process after is a method on the base controller
      elsif options.shell and args.any?
        # call(:shell, :bash)
        # target.runtime.exec(args.last, :bash)
      end
    end

    def execute_on_target
      return unless request.services.size.positive?

      Dir.chdir(target.exec_path)  do
        with_spinner('Building...') do
          binding.pry
          command_options = {uuid: false}
          cmd_options = {}
          command(command_options).run!(runtime.build(request), cmd_options)
        end
      end
    end

    # def limits
    #   { deployments: 1 }
    # end

    def publish_results
      require 'tty-table'
      table = TTY::Table.new(['Commands', 'Errors'], errors.messages.to_a)
      output.puts "\n"
      output.puts table.render(:basic, alignments: [:left, :left], padding: [0, 4, 0, 0])
    end

    def with_spinner(spin_msg)
      if options.quiet
        require 'tty-spinner'
        spinner = TTY::Spinner.new("[:spinner] #{spin_msg}", format: :pulse_2)
        spinner.auto_spin # Automatic animation with default interval
      end
      result = yield
      if options.quiet
        spinner_msg = result.failure? ? 'Failed!' : 'Done!'
        spinner.stop(spinner_msg)
      end
      errors.add(:build, result.err.chomp) if result.failure?
    end
  end
end
