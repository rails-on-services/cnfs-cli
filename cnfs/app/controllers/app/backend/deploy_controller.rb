# frozen_string_literal: true

module App::Backend
  class DeployController < Cnfs::Command

    def on_execute
      generate_config
      runtime.deploy
      execute(:status)
      # after_execute :execute_on_service
    end

    def generate_config
      options[:continue] = prompt.yes?('Are you sure?')
      binding.pry
      # output.puts 'NOT regenerating config' if options.v and not stale_config
      # return unless stale_config
      # TODO: generate_config code
    end

    # This is the entrypoint of the command
    # def execute_command(args) # (input: $stdin, output: $stdout)
    #   if services.empty?
    #     deploy_enabled_services
    #     # TODO: set services so #execute_on_service method will work
    #     # services = enabled_services
    #   else
    #     deploy_services
    #   end
    #   # reload_nginx(services)
    # end


    # NOTE: only one of console, shell or attach can be passed
    def execute_on_service
      if options.console
        output.puts 'Post running console'
        execute(:console, services.last)
      elsif options.shell
        output.puts 'Post running shell'
        execute(:exec ,services.last, 'bash')
      elsif options.attach
        output.puts 'Post running attach'
        execute(:attach, services.last)
      end
    end


    # This is a method from rails
    # TODO: move this to the rails module
    def console(service)
      exec(service, 'rails console')
    end

    def attach(service)
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
