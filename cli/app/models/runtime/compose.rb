# frozen_string_literal: true

class Runtime::Compose < Runtime
  # What to do about this one?
  def x_method_missing(method, *args)
    binding.pry
    # response.output.puts('command not supported in compose runtime')
    raise Cnfs::Error, 'command not supported in compose runtime'
  end

  def supported_commands
    %w[build test push pull publish
       destroy deploy redeploy 
       start restart stop terminate
       ps status
       attach command console copy credentials exec logs shell]
    # list show generate
  end

  # Image Operations
  def build(services)
    rv compose("build --parallel #{services.pluck(:name).join(' ')}")
  end

  def pull(services)
    rv compose("pull #{services.pluck(:name).join(' ')}")
  end

  def push(services)
    rv compose("push #{services.pluck(:name).join(' ')}")
  end

  # Namespace Operations
  # TODO: Add support for destroying volumes; https://docs.docker.com/compose/reference/down/
  def destroy
    rv compose(:down)
  end

  def deploy
    rv compose(:up)
  end

  def redeploy
    [destroy, deploy]
  end

  def status; end

  # Service Process Operations
  def ps(xargs)
    tool_check
    running_services(format: options.format, status: options.status, **xargs)
  end

  # Service Admin Operations
  def start(services)
    rv compose("up #{compose_options} #{services.pluck(:name).join(' ')}")
  end

  def stop(services)
    rv compose("stop #{services.pluck(:name).join(' ')}")
  end

  def restart(services)
    [stop(services), start(services)]
    # TODO: Implement this; If a service has a method then it gets called
    # if options.clean
    #   clean
    #   database_check
    # end
  end

  def terminate(services)
    [stop(services), clean(services)]
  end

  # Service Runtime
  def attach(service)
    rv "docker attach #{service.full_context_name}_#{service.name}_1 --detach-keys='ctrl-f'"
  end

  def copy(service, src, dest)
    container_id = service_id(service)
    rv "docker cp #{src} #{dest}".gsub("#{service.name}:", "#{container_id}:")
  end

  # TODO: Needs filter for profile and adjust for 'server'
  def exec(service, command, pty)
    filters = { project: service.full_context_name, service: service.name }
    # filters.merge!(profile: profile_name) if profile_name
    services = running_services(filters)
    modifier = services.empty? ? 'run --rm' : 'exec'
    [compose_env, compose(command, modifier, service.name), { pty: pty }]
    # response.add(exec: compose(command, modifier, service.name), pty: pty)
  end

  def logs(service)
    # TODO: Query running services to get the name
    # TODO: Get options available in the runtime
    # command_options = { pty: options.tail }
    rv "docker logs #{compose_options} #{service.full_context_name}_#{service.name}_1"
  end

  #### Support Methods

  def switch!
    FileUtils.rm_f('.env')
    FileUtils.ln_s(compose_file, '.env') if File.exist?(compose_file)
    Cnfs.invoke_plugins_with(:on_runtime_switch)
  end

  def compose_file
    @compose_file ||= runtime_path.join('compose.env')
  end

  def service_id(service)
    command.run(compose_env, "docker-compose ps -q #{service.name}", command_options).out
  end

  def running_services_names(status: :running)
    running_services(status: status).map { |a| a.gsub("#{project.name}_", '').chomp('_1') }
  end

  # See: https://docs.docker.com/engine/reference/commandline/ps
  def running_services(format: '{{.Names}}', status: :running, **filters)
    @running_services ||= running_services_query(format: format, status: status, **filters)
  end

  private

  # Simplified syntax to return a command array
  def rv(command_string)
    tool_check
    [compose_env, command_string, command_options]
  end

  def tool_check
    missing_tools = required_tools - Cnfs.capabilities
    raise Cnfs::Error, "Missing #{missing_tools}" if missing_tools.any?
  end

  def required_tools
    %i[docker docker-compose]
  end

  def compose(command, *modifiers)
    modifiers.unshift('docker-compose').append(command).join(' ')
  end

  def compose_env
    @compose_env ||= set_compose_env
  end

  def set_compose_env
    hash = {}
    # Call each plugin passing in the command object and the env hash
    Cnfs.invoke_plugins_with(:set_compose_env, silent_command, hash)
    hash
  end

  # options embedded in the compose command string
  def compose_options
    opts = []
    opts.append('-d') if options.foreground
    opts.append('-f') if options.tail
    opts.join(' ')
  end

  # options returned to the TTY command
  def command_options
    opts = {}
    opts.merge!(pty: true) if 1 == 2
    opts.merge!(only_output_on_error: true) if project.options.quiet
    opts
  end

  # TODO: commands need to handle profiles
  # def exec_string
  #   application.services.each_with_object([]) do |service, ary|
  #     binding.pry
  #     (options.profiles || service.try(:profiles)&.keys || {}).each do |profile|
  #       profile = profile.eql?(default_profile) ? '' : "_#{profile}"
  #       ary.append("#{service.name}#{profile}")
  #     end
  #   end.join(' ')
  # end

  # TODO: make this a configuration option
  # def default_profile
  #   'server'
  # end

  # def runtime_service_names_to_service_names(runtime_services_list)
  #   runtime_services_list.map { |a| a.gsub("#{project.full_context_name}_", '')[0...-2] }
  # end

  def running_services_query(format:, status:, **filters)
    filter = filters.each_pair.map { |key, value| "--filter 'label=#{key}=#{value}'" }
    filter.append("--filter 'status=#{status}'") if status
    filter.append("--format '#{format}'") if format

    silent_command.run(compose_env, "docker ps #{filter.join(' ')}", command_options).out.split("\n")
    # return an array of service strings minus the header
    # result
    # Cnfs.logger.info(result)
    # result.size.positive? ? result.drop(1) : []
  end

  def silent_command
    TTY::Command.new(printer: :null)
  end

  # TODO: taken from deploy command; is it needed/appropriate here?
  # def set_compose_options
  #   @compose_options = ''
  #   if options.daemon || options.console || options.shell || options.attach
  #     @compose_options = '-d'
  #   end
  #   output.puts "compose options set to #{compose_options}" if options.verbose
  # end

  def clean(services)
    [compose_env, compose("stop #{services.pluck(:name).join(' ')}"), { tty: true }]
  end

  def deploy_type
    :instance
  end

  # TODO: This will be an interesting task
  def database_check
    application.services.each do |service|
      next unless service.respond_to?(:database_seed_commands)

      migration_file = "#{runtime_path}/#{service.name}-migrated"
      next unless !File.exist?(migration_file) || options.seed || options.clean

      FileUtils.rm(migration_file) if File.exist?(migration_file)
      service.database_seed_commands.each do |command|
        response.add(exec: compose(command, service.name)) # .run!
        # TODO: refactor; this knows too much about what's going on in the response object
        if response.errors.size.zero?
          FileUtils.touch(migration_file)
        else
          break
        end
      end
    end
  end
end
