# frozen_string_literal: true

module App::Backend
  class TestController < Cnfs::Command
    # before_execute :generate_manifests
    # after_execute :show_results

    # def show_results
    def on_execute
      generate_manifests
      # binding.pry
      if errors.size.positive?
        output.puts(errors.messages.map{ |(k, v)| "#{v}\n" })
        Kernel.exit(errors.size)
      end
    end
#   end
# end
# # frozen_string_literal: true
# 
# module Cnfs::Commands::Application
#   module Backend::Test::Compose
# 
#       def self.included(base)
#         base.include Cnfs::Commands::Compose
#         base.on_execute :run_compose
#       end

      # def exec(service, command)
      #   # generate_config if stale_config
      #   build([service]) if command.eql?('bash') and options.build
      #   run_string = services.include?(service) ? 'exec' : 'run --rm'
      #   compose("#{run_string} #{service} #{command}", true)
      # end

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

      # TODO: Move to compose concern that is included here
      def running_services
        []
        # test_commands(service).each do |test_command|
        #   exec(service, test_command)
        #   next if exit_code.zero?
        #   errors.add("#{service} #{test_command}", "#{service} failed on #{test_command}")
        #   break if options.fail_fast
        # end
        # out, err = command(printer: :null).run('docker-compose ps')
        # res = out.split("\n")[2..].map { |line| line.split[0] }
        # @result = "#{res.join("\n")}"
      end
    end
  end
# end
