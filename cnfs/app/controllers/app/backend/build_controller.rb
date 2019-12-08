# frozen_string_literal: true

module App::Backend
  class BuildController < Cnfs::Command
    def execute
      binding.pry
      # generate_manifests
      with_spinner('Building...') do
        command(command_options).run!(target.runtime.build(services), cmd_options)
      end
      if errors.size.positive?
        publish_results
        Kernel.exit(errors.size)
      elsif options.shell and args.any?
        # call(:shell, :bash)
        # target.runtime.exec(args.last, :bash)
      end
    end

    # TODO: move these to the base class or a shared concern
    def services
      @services ||= args.any? ? args : (deployment.application.services.pluck(:name) +
        target.services.pluck(:name)) 
    end

    def target
      @target ||= deployment.targets.find_by(name: options.target) || deployment.targets.first
    end

    # def layer
    #   @layer ||= deployment.targets.find_by(name: options.layer) || layers.first
    # end

    # def layers
    #   @layers ||= (deployment.application.layers.pluck(:name) + target.layers.pluck(:name))
    # end

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
