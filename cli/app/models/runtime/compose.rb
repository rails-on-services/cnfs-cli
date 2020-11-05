# frozen_string_literal: true

class Runtime::Compose < Runtime
  def supported_commands
    %w[build test push pull publish
       destroy
       deploy redeploy ps status
       start restart stop terminate
       attach command console copy credentials exec logs shell]
    # list show generate
  end

  def services_to_string(services)
    services.pluck(:name).join(' ')
  end

  ###
  # Image Operations
  ###
  def build(services)
    response.add(exec: compose("build --parallel #{services_to_string(services)}"), env: compose_env)
  end

  def pull(services)
    response.add(exec: compose("pull #{services_to_string(services)}"), env: compose_env)
  end

  ###
  # Cluster Admin
  ###
  def destroy
    response.add(exec: compose(:down), env: compose_env)
  end

  ###
  # Cluster Runtime
  ###
  def deploy
    response.add(exec: compose(:up), env: compose_env)
  end

  def redeploy
    response.add(exec: compose(:down), env: compose_env)
    response.add(exec: compose(:up), env: compose_env)
  end

  def ps; end

  def status; end

  ###
  # Service Runtime
  ###
  def start
    compose_options = options.foreground ? '' : '-d'
    response.add(exec: compose("up #{compose_options} #{exec_string}"), env: compose_env)
  end

  def restart
    stop
    if options.clean
      clean
      database_check
    end
    start
  end

  def stop
    response.add(exec: compose("stop #{exec_string}"), env: compose_env)
  end

  def terminate
    stop
    clean
  end

  def exec_string
    application.services.each_with_object([]) do |service, ary|
      (options.profiles || service.profiles.keys).each do |profile|
        profile = profile.eql?(default_profile) ? '' : "_#{profile}"
        ary.append("#{service.name}#{profile}")
      end
    end.join(' ')
  end

  # TODO: make this a configuration option
  def default_profile; 'server' end

  ###
  # Service Runtime
  ###
  # TODO: add support for profile
  def attach(service)
    response.add(exec: "docker attach #{application.full_project_name}_#{service.name}_1 --detach-keys='ctrl-f'", pty: true)
  end

  def copy(src, dest)
    service_name = src.index(':') ? src.split(':')[0] : dest.split(':')[0]
    response.add(exec: "docker cp #{src} #{dest}".gsub("#{service_name}:", "#{service_id(service_name)}:"))
  end

  # TODO: Needs filter for profile and adjust for 'server'
  def exec(service, command, pty)
    filters = { project: application.full_project_name, service: service.name }
    # filters.merge!(profile: profile_name) if profile_name
    running_services = runtime_services(filters)
    modifier = running_services.empty? ? 'run --rm' : 'exec'
    response.add(exec: compose(command, modifier, service.name), pty: pty)
  end

  def logs(service)
    compose_options = options.tail ? '-f' : ''
    # TODO: Query running services to get the name
    response.add(exec: "docker logs #{compose_options} #{application.full_project_name}_#{service.name}_1", pty: options.tail)
  end

  #### Support Methods

  def before_execute
    switch!
  end

  def switch!
    FileUtils.rm_f('.env')
    FileUtils.ln_s(compose_file, '.env') if File.exist?(compose_file)
    # TODO: This is specific to a Cnfs Backend project
    # Dir.chdir("#{Cnfs.application.root}/services") do
    #   FileUtils.rm_f('.env')
    #   FileUtils.ln_s("../#{target.write_path}", '.env')
    # end
    # unless config.platform.is_cnfs?
    #   Dir.chdir("#{Cnfs.application.root}/ros/services") do
    #     FileUtils.rm_f('.env')
    #     FileUtils.ln_s("../../#{write_path}", '.env')
    #   end
    # end
  end

  def compose_file
    # binding.pry
    # @compose_file ||= "#{runtime_path}/compose.env"
    @compose_file ||= runtime_path + 'compose.env'
    # @compose_file ||= runtime_path.join('compose.env')
  end

  def service_id(service_name)
    `docker-compose ps -q #{service_name}`.chomp
  end

  def service_names(status: :running)
    runtime_services(status: status).map { |a| a.gsub("#{application.project_name}_", '').chomp('_1') }
  end

  # See: https://docs.docker.com/engine/reference/commandline/ps
  def runtime_services(format: '{{.Names}}', status: :running, **filters)
    @runtime_services ||= runtime_services_query(format: format, status: status, **filters)
  end


  private

  def compose(command, *modifiers)
    modifiers.unshift('docker-compose').append(command).join(' ')
  end

  def runtime_service_names_to_service_names(runtime_services_list)
    runtime_services_list.map { |a| a.gsub("#{application.full_project_name}_", '')[0...-2] }
  end

  def compose_env
    hash = {}
    hash.merge!('GEM_SERVER' => "http://#{gem_cache_server}:9292") if gem_cache_server
    hash
  end

  def runtime_services_query(format:, status:, **filters)
    filter = filters.each_pair.map { |key, value| "--filter 'label=#{key}=#{value}'" }
    filter.append("--filter 'status=#{status}'") if status
    filter.append("--format '#{format}'") if format

    command_string = "docker ps #{filter.join(' ')}"
    result = `#{command_string}`
    response.output.puts command_string if options.verbose
    rsplit = result.split("\n")
    rsplit.size.positive? ? rsplit : []
  end

  # TODO: taken from deploy command; is it needed/appropriate here?
  # def set_compose_options
  #   @compose_options = ''
  #   if options.daemon || options.console || options.shell || options.attach
  #     @compose_options = '-d'
  #   end
  #   output.puts "compose options set to #{compose_options}" if options.verbose
  # end

  def clean
    response.add(exec: compose("rm -f #{exec_string}"))
  end

  def deploy_type
    :instance
  end

  def gem_cache_server
    return unless Cnfs.capabilities.include?(:docker) and `docker ps`.index('gem_server')

    host = RbConfig::CONFIG['host_os']
    # TODO: Make this configurable per user
    return `ifconfig vboxnet1`.split[7] if host =~ /darwin/

    `ip -o -4 addr show dev docker0`.split[3].split('/')[0]
  end

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

  def x_method_missing(method, *args)
    binding.pry
    # response.output.puts('command not supported in compose runtime')
    raise Cnfs::Error, 'command not supported in compose runtime'
  end
end
