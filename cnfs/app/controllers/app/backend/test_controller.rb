# frozen_string_literal: true

module App::Backend
  class TestController < Cnfs::Command
    def execute
      with_selected_target do
        before_execute_on_target
        call(:build) if options.build
        execute_on_target
      end
    end

    def execute_on_target
      request.services.each do |service|
        service.test_commands(options.rspec_options).each do |test_command|
          output.puts test_command
          runtime.exec(service.name, test_command)
          # next if exit_code.zero?
          # errors.add("#{service} #{test_command}", "#{service} failed on #{test_command}")
          # break if options.fail_fast
        end
        # TODO: push is after each test or at the end of all tests?
        # TODO: first check if this is still being used by ci...
        # break if errors.size.positive? and options.fail_all
        # push([service]) if errors.size.zero? and options.push
      end

      # if errors.size.positive?
      #   output.puts(errors.messages.map{ |(k, v)| "#{v}\n" })
      #   Kernel.exit(errors.size)
      # end
    end

    def run_compose
      # TODO: Each service has a type
      # TODO: Services need to be accessible from the backend object
      services.each do |service|
        service_config = config.platform.application.backend.rails.settings.units.dig(service)
        test_commands = config.platform.application.backend.rails.config.dig(:commands, :test)
        cmd = ['docker-compose']
        cmd << (running_services.include?(service) ? 'exec' : 'run --rm')
        cmd << service
        test_commands.each do |command|
          run_cmd = cmd.dup.append(command).join(' ')
          result = command(command_options).run!(run_cmd, cmd_options)
          # result = command(command_options).run!("docker-compose #{run_string} #{service} #{command}", cmd_options)
          # result = command(command_options).run!({'RAILS_ENV' => 'test'}, "docker-compose #{run_string} #{service} #{command}", cmd_options)
          next unless result.failure?
          errors.add("#{service} #{command}", "#{service} failed on #{command}")
          # errors.add("#{service} #{command}", result.err)
          break if options.fail_fast
        end
      end
    end
  end
end
