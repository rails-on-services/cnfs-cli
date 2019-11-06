# frozen_string_literal: true

module Cnfs::Commands::Application
  class Backend::Build < Cnfs::Command
    module Compose

      def self.included(base)
        base.on_execute :run_compose
        base.on_execute :run_shell
      end

      def run_compose
        # generate_config if stale_config
        # with_spinner
        require 'tty-spinner'
        spinner = TTY::Spinner.new('[:spinner] Building...', format: :pulse_2)
        spinner.auto_spin # Automatic animation with default interval
        result = command(command_options).run!("docker-compose build --parallel #{services.join(' ')}", cmd_options)
        spinner_msg = result.failure? ? 'Failed!' : 'Done!'
        spinner.stop(spinner_msg)
        errors.add(:build, result.err) if result.failure?
      end

      def run_shell
        compose(services.last, :bash) if errors.size.zero?
      end

      def compose(service, command)
        cmd = ['docker-compose']
        cmd << (running_services.include?(service) ? 'exec' : 'run --rm')
        cmd.append(service).append(command)
        output.puts(cmd.join(' ')) if options.verbose
        # cmd = TTY::Command.new(pty: true).run(cmd.join(' '))
        system(cmd.join(' '))
      end

      def running_services
        @running_services ||= Cnfs::Commands::Application::Backend::Ps.new(options).execute.result
      end
    end
  end
end
