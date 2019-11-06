# frozen_string_literal: true

module Cnfs::Commands::Application
  class Backend::Deploy < Cnfs::Command
    attr_accessor :services, :options, :platform, :compose_options
    # TODO: Implement conditionals on the callbacks (maybe)
    # TODO: Use a method that returns a Cnfs::Core::Platform class rather than direct access to Cnfs.platform
    # so that any instance of that class can be returned

    def initialize(services, options, platform = Cnfs.platform)
      @services = services
      @options = options
      @platform = platform
      type = :compose
      self.class.include(self.class.registrations[type]) if self.class.registrations[type]
      # TODO: could include any additional registrations
      # Perhaps the registrations needs to be more capable, e.g. the registration type as in
      # for a service 'rails', for an orchestrator, 'compose' or 'k8s'
    end
    # def execute #(args) # input: $stdin, output: $stdout)
    #   with_callbacks([]) do
    #     output.puts(result)
    #   end
    #   output.puts 'PS OK'
    # end

    # Invoke the generate command
    before_execute :generate_config
    after_execute :show_status
    after_execute :execute_on_service

    def generate_config
      options[:continue] = prompt.yes?('Are you sure?')
      binding.pry
      # output.puts 'NOT regenerating config' if options.v and not stale_config
      # return unless stale_config
      # TODO: generate_config code
    end

    # This is the entrypoint of the command
    def execute_command(args) # (input: $stdin, output: $stdout)
      if services.empty?
        deploy_enabled_services
        # TODO: set services so #execute_on_service method will work
        # services = enabled_services
      else
        deploy_services
      end
      # reload_nginx(services)
    end

    def show_status
      output.puts 'the status is ...'
      # TODO: Output from the status command
    end

    # NOTE: only one of console, shell or attach can be passed
    def execute_on_service
      if options.console
        output.puts 'Post running console'
        console(services.last)
      elsif options.shell
        output.puts 'Post running shell'
        exec(services.last, 'bash')
      elsif options.attach
        output.puts 'Post running attach'
        attach(services.last)
      end
    end

    # NOTE: This should be in the generator class, e.g. compose
    # def execute_command(args) # (input: $stdin, output: $stdout)
    #   generator_class.new([], { values: platform.application.backend }, {}).invoke_all
    #   output.puts 'DEPLOY OK'
    # end
  end
end
