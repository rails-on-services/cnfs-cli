# frozen_string_literal: true

module Primary
  class BuildController < ApplicationController
    def execute
      services.each do |service|
        Dir.chdir(service.path || application.path) do
          # target.runtime.build(service)
          binding.pry
        end
      end
    end

    def services; @services ||= application.services.where(name: args.service_names) end

    def application; @application ||= Application.find_by(name: args.application_name) end

    def x
      with_selected_target do
        before_execute_on_target
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
      with_spinner('Building...') do
       command(command_options).run!(runtime.build(request), cmd_options)
      end
    end

    def publish_results
      require 'tty-table'
      table = TTY::Table.new(['Commands', 'Errors'], errors.messages.to_a)
      output.puts "\n"
      output.puts table.render(:basic, alignments: [:left, :left], padding: [0, 4, 0, 0])
    end

    def with_spinner(spin_msg)
      unless options.verbose
        require 'tty-spinner'
        spinner = TTY::Spinner.new("[:spinner] #{spin_msg}", format: :pulse_2)
        spinner.auto_spin # Automatic animation with default interval
      end
      result = yield
      unless options.verbose
        spinner_msg = result.failure? ? 'Failed!' : 'Done!'
        spinner.stop(spinner_msg)
      end
      errors.add(:build, result.err.chomp) if result.failure?
    end
  end
end
