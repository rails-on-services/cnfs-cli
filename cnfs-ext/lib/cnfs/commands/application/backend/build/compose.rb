# frozen_string_literal: true

module Cnfs::Commands::Application
  module Backend::Build::Compose

    def self.included(base)
      base.include Cnfs::Commands::Compose
      base.on_execute :run_compose
      base.on_execute :run_shell
    end

    def run_compose
      # TODO: trigger service generation
      # generate_config if stale_config
      with_spinner('Building...') do
        command(command_options).run!("docker-compose build --parallel #{requested_services.join(' ')}", cmd_options)
      end
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
      errors.add(:build, result.err) if result.failure?
    end

    def run_shell
      return if requested_services.size.zero? or errors.size.positive?
      compose(requested_services.last, :bash) if options.shell
    end
  end
end
