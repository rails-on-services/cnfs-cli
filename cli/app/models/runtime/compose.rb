# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class Runtime::Compose < Runtime
  # attr_accessor :queue, :services, :context

  # delegate :options, :labels, to: :context

  # TODO: Is this necessary?
  def supported_service_types
    ['Service::Rails', nil]
  end

  # What to do about this one?
  # def method_missing(method, *args)
  #   Cnfs.logger.warn 'command not supported in compose runtime'
  #   raise Cnfs::Error, 'command not supported in compose runtime'
  # end

  # def supported_commands
  #   %w[build test push pull publish
  #      destroy deploy redeploy
  #      start restart stop terminate
  #      ps status
  #      attach command console copy credentials exec logs shell]
  #   # list show generate
  # end

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
  def ps(_xargs)
    # TODO: queue.add(switch!)
    switch!
    queue.add(rv(compose('ps')))
    # tool_check
    # query(format: options.format, status: options.status, **xargs)
  end

  def tc
    @tc ||= Command.new(
      # opts: context.options,
      env: { this: 'that' },
      exec: 'ls -la',
      opts: context.options.merge(printer: :null)
    )
  end
      # qc = Command.new(
      #   env: { hey: :now },
      #   exec: compose_command("up #{compose_options} #{services.pluck(:name).join(' ')}"),
      #   opts: context.options.merge(printer: :null)
      #   # opts: context.options,
      # )
      # queue.append(qc, tc)
      # tc.run(exec: 'ls -w')
      # binding.pry
      # queue.append(tc)

  # Service Admin Operations
  def start
    run_callbacks :execute do
      # runtime_services.select{ |s| s.image.eql?('postgres') }
      queue.append(compose_command(exec: :up))
      yield queue
    end

    # At this point the services have been queried both before and after the commands have run
    # TODO: Is this the best way to have any services run their callbacks after a state change?

    running_before = []
    running_after = query.result.to_a.append('iam')

    (running_after - running_before).each do |_service_name|
      next unless (service = context_services.select { |s| s.name.eql?('iam') }.first)

      service.update(state: :started)
      # TODO: This returns an array of commands to run on the service
      # Stuff this into the commands queue with docker-compose exec blah blah...
      q = service.command_queue
      queue.append(compose_command(exec: "exec #{q.first}"))
      yield queue
      # puts q
      # binding.pry
      # end
    end
  end

  before_execute :generate, :write_env, :query_services

  def write_env
    FileUtils.rm_f('.env')
    FileUtils.ln_s(compose_file, '.env') if File.exist?(compose_file)
    Cnfs.logger.debug("Linked #{compose_file} to .env")
    # ActiveSupport::Notifications.instrument('on_runtime_switch.cli')
    true
  end

  def query_services
    query.result.to_a.each do |json|
      runtime_services.create(docker: JSON.parse(json))
    rescue JSON::ParserError => e
      binding.pry
    end
  end

  # See: https://docs.docker.com/engine/reference/commandline/ps
  # TODO: Add filter for labels so only getting containers managed for this context
  def query(format: :names, status: :running, **filters)
    filter = filters.each_pair.map { |key, value| "--filter 'label=#{key}=#{value}'" }
    # filter.append("--format '#{query_format_map[format]}'") if format
    # filter.append("--filter 'status=#{status}'") if status
    # filter = "table {{.ID}}\\t{{.Status}}\\t{{.Ports}}"
    # command.run(exec: "docker ps --format \"#{filter}\"", opts: { silent: true })
    # docker ps --format '{"ID":"{{ .ID }}", "Image": "{{ .Image }}", "Names":"{{ .Names }}"}'
   
    # working = %q[docker ps --format '{"ID":"{{ .ID }}", "Image": "{{ .Image }}", "Names":"{{ .Names }}"}']
    # try = %w[ID Image Names].each_with_object([]) do |item, ary|
    #   ary.append("\"#{item}\":\"{{ .#{item} }}\"")
    # end
    # try = "docker ps --format '{#{try.join(', ')}}'"
    try = "docker ps -a --format '{#{query_string.join(', ')}}'"
    # binding.pry
    # rworking =command.run(exec: working, opts: { silent: true })
    rtry = command.run(exec: try, opts: { silent: true })
    # binding.pry
    rtry

    # command.run(exec: "docker ps #{filter.join(' ')}", opts: { silent: true })
  end

  def query_string(hash = query_hash)
    hash.each_with_object([]) do |(key, value), ary|
      ary.append("\"#{key}\":\"{{ .#{value} }}\"")
    end
  end

  def query_hash
    # { rid: :ID, image: :Image, names: :Names, command: :Command, labels: :Labels, status: :Status, ports: :Ports }
    { rid: :ID, image: :Image, names: :Names, labels: :Labels, status: :Status, ports: :Ports }
  end

  def query_format_map
    { names: '{{.Names}}' }
  end


    # TODO:
    # 1. Base runtime class has a query interface, i.e. a set of methods to implement by each runtime which
    #    returns a standard set of results, e.g. the running container names
    # 2. Compose implements these methods
    # 3. Before calling start this controller gets the list of running containers
    # 4. After start get a revised list and compare the two lists
    # 5. Any service that was not running and not is running then has it's state changed

    # TODO: if the queue has meta data with the service command to invoke and this is in a command class
    # Then the class could auto invoke the command which triggers any callbacks
    # result = command.run!(*cmd_array)
    # raise Cnfs::Error, result.err if result.failure?

    # runtime_services.each do |service|
    #   # Trigger the service's after_start callbacks which may add commands to the service's command_queue
    #   service.start
    #   service.command_queue.each do |cmd_array|
    #     Cnfs.logger.debug cmd_array
    #     result = command.run!(*cmd_array)
    #     Cnfs.logger.error(result.err) if result.failure?
    #   end
    # end

  def stop(services)
    queue.add(rv(compose("stop #{services.pluck(:name).join(' ')}")))
  end

  def restart(services)
    stop(services)
    start(services)
    # [stop(services), start(services)]
    # TODO: Implement this; If a service has a method then it gets called
    # if options.clean
    #   clean
    #   database_check
    # end
  end

  def terminate(services)
    stop(services)
    clean(services)
    # [stop(services), clean(services)]
  end

  # Service Runtime
  def attach(service)
    rv "docker attach #{service.full_context_name}_#{service.name}_1 --detach-keys='ctrl-f'"
  end

  def copy(service, src, dest)
    container_id = running_service_id(service)
    rv "docker cp #{src} #{dest}".gsub("#{service.name}:", "#{container_id}:")
  end

  # TODO: Needs filter for profile and adjust for 'server'
  def exec(service, command, pty)
    filters = { project: service.full_context_name, service: service.name }
    # filters.merge!(profile: profile_name) if profile_name
    services = query(filters)
    modifier = services.empty? ? 'run --rm' : 'exec'
    [command_env, compose(command, modifier, service.name), { pty: pty }]
    # response.add(exec: compose(command, modifier, service.name), pty: pty)
  end

  def logs(service)
    # TODO: Query running services to get the name
    # TODO: Get options available in the runtime
    # command_options = { pty: options.tail }
    rv "docker logs #{compose_options} #{service.full_context_name}_#{service.name}_1"
  end

  #### Support Methods

  # NOTE: This was an interface with CommandHelper
  # def prepare
  # end

  def compose_file
    @compose_file ||= context.path(to: :runtime).join('compose.env')
  end

  def running_service_id(service)
    command.run(command_env, "docker-compose ps -q #{service.name}", command_options).out.strip
  end

  # TODO: This should query based on a label
  def running_services_names(status: :running)
    query(status: status).map { |a| a.gsub("#{project.name}_", '').chomp('_1') }
  end

  private

  #   def required_tools
  #     %w[docker docker-compose]
  #   end
  #
  #   def compose(command, *modifiers)
  #     modifiers.unshift('docker-compose').append(command).join(' ')
  #   end
  #
  #   def command_env
  #     @command_env ||= set_compose_env
  #   end
  #
  #   def set_compose_env
  #     hash = {}
  #     # Notify listeners passing in the command object and the env hash
  #     ActiveSupport::Notifications.instrument 'set_compose_env.cli', { command: silent_command, hash: hash }
  #     hash
  #   end

  # options embedded in the compose command string
  # rubocop:disable Metrics/AbcSize
  def compose_options
    location = 1
    method = caller_locations(1, location)[location - 1].label
    opts = []
    # binding.pry
    opts.append('-d') if server_commands.include?(method) && !context.options.foreground
    opts.append('-f') if context.options.tail
    Cnfs.logger.debug "compose options set to #{opts.join(' ')}"
    opts.join(' ')
  end
  # rubocop:enable Metrics/AbcSize

  def server_commands
    %w[start]
  end

  #   # TODO: commands need to handle profiles
  #   # def exec_string
  #   #   application.services.each_with_object([]) do |service, ary|
  #   #     binding.pry
  #   #     (options.profiles || service.try(:profiles)&.keys || {}).each do |profile|
  #   #       profile = profile.eql?(default_profile) ? '' : "_#{profile}"
  #   #       ary.append("#{service.name}#{profile}")
  #   #     end
  #   #   end.join(' ')
  #   # end
  #
  #   # TODO: make this a configuration option
  #   # def default_profile
  #   #   'server'
  #   # end
  #
  #   # def runtime_service_names_to_service_names(runtime_services_list)
  #   #   runtime_services_list.map { |a| a.gsub("#{project.full_context_name}_", '')[0...-2] }
  #   # end

  # BEGIN: new stuff
  #
  # def compose_command(exec:, env: command_env, x_services: services)
  #   queue_command(exec: compose(:up))
  # end

  # def queue_command(env: command_env, exec:)
  #   Command.new(
  #     env: env,
  #     exec: exec,
  #     opts: context.options
  #   )
  # end

  # , opts:)
  def compose_command(exec:, env: {})
    command(exec: compose_exec(exec), env: compose_env.merge(env)) # , opts: compose_opts.merge(opts))
  end

  def compose_exec(exec)
    "docker-compose #{exec} #{compose_options} #{context_services.pluck(:name).join(' ')}"
  end

  def compose_env(**env)
    {}.merge(env)
  end

  # def compose_opts(**opts)
  #   {}.merge(opts)
  # end

  def command(exec: nil, env: {}, opts: {})
    Command.new(exec: exec, env: env, opts: context.options.merge(opts))
  end

  # END: new stuff

  def silent_command
    TTY::Command.new(printer: :null)
  end

  def clean(services)
    queue.add [command_env, compose("rm -f #{services.pluck(:name).join(' ')}"), command_options]
  end
end
# rubocop:enable Metrics/ClassLength
