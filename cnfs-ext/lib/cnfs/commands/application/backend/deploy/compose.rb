# frozen_string_literal: true

module Cnfs::Commands::Application
  class Backend::Deploy < Cnfs::Command
    module Compose
      def self.included(base)
        base.before_validate :set_compose_options
      end

      def set_compose_options
        @compose_options = ''
        if options.daemon or options.console or options.shell or options.attach
          @compose_options = '-d'
        end
        output.puts "compose options set to #{compose_options}" if options.verbose
      end

      # This is a method from rails
      # TODO: move this to the rails module
      def console(service)
        exec(service, 'rails console')
      end

      def attach(service)
        # project_name = Ros::Be::Application::Model.compose_project_name
        # system_cmd("docker attach #{project_name}_#{service}_1 --detach-keys='ctrl-f'", {}, true)
      end

      def exec(service, command)
        # generate_config if stale_config
        # build([service]) if command.eql?('bash') and options.build
        run_string = services.include?(service) ? 'exec' : 'run --rm'
        compose("#{run_string} #{service} #{command}", true)
      end

      def deploy_enabled_services
        compose(:build) if options.build
        # TODO: What about seeding the database if requested?
        compose(:up)
      end

      def compose(action, boolean = true)
        output.puts "running 'compose #{action}'"
        # TODO: Use the tty console gem to execute compose commands
      end

      def exit_code; 0 end
       
      def deploy_services
        services.each do |service|
          # if the service name is without a profile extension, e.g. 'iam' then load config and check db migration
          # If the database check is ok then bring up the service and trigger a reload of nginx
          if options.build
            compose("build #{service}")
            if exit_code.positive?
              errors.add(:build, 'see terminal output')
              next
            end
          end
          # if ref = svc_config(service)
          #   config = ref.dig(:config) || Config::Options.new
          #   next unless database_check(service, config) unless config.type&.eql?('basic')
          # end
          compose("up #{compose_options} #{service}")
          errors.add(:up, 'see terminal output') if exit_code.positive?
        end
      end
    end
  end
end
