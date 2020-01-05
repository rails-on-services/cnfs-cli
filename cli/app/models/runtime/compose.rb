# frozen_string_literal: true

class Runtime::Compose < Runtime
  def attach(request)
    # system_cmd("docker attach #{runtime.project_name}_#{service}_1 --detach-keys='ctrl-f'", {}, true)
    system("docker attach #{project_name}_#{request.last_service_name}_1 --detach-keys='ctrl-f'")
    # "docker attach #{project_name}_#{service}_1 --detach-keys='ctrl-f'"
  end

  # TODO: are these commands returning strings or executing commands or both?
  def build(request)
    # switch!
    "docker-compose build --parallel #{request.service_names_to_s}"
  end

  def copy(src, dest)
    # TODO: Move the param handling to base runtime class 
    src_service = src.include?(':')
    dest_service = dest.include?(':')
    raise ArgumentError.new("only one of source or destination can be a service") if src_service and dest_service
    raise ArgumentError.new("source or destination must be a service") unless src_service or dest_service
    service = src_service ? src.split(':')[0] : dest.split(':')[0]
    stdout = `docker-compose ps -q #{service}`
    container_id = stdout.chomp
    if src_service
      src = src.gsub("#{service}:", "#{container_id}:")
    else
      dest = dest.gsub("#{service}:", "#{container_id}:")
    end
    system("docker cp #{src} #{dest}")
  end

  def create(request)
    # NOTE: For docker this is a noop function as deploy is all that is needed
  end

  def deploy(request); start(request) end

  def destroy(request)
    if request.services.any?
      terminate(request)
    else
      compose_cmd(:down)
      clean_cache(request)
    end
  end

  def exec(service_name, command)
    compose(service_name, command, options)
  end

  def logs(service_name)
    compose_options = options.tail ? '-f' : ''
    system("docker logs #{compose_options} #{project_name}_#{service_name}_1") # , {}, true)
  end

  def restart(request)
    stop(request)
    start(request)
  end

  def start(request)
    # if options.clean
    #   compose_cmd("rm -f #{request.service_names_to_s}")
    #   clean_cache(request)
    # end
    terminate(request) if options.clean
    compose_options = options.foreground ? '' : '-d'
    compose_cmd("up #{compose_options} #{request.service_names_to_s}")
    request.services.each { |service| database_check(service) }
  end

  def stop(request)
    compose_cmd("stop #{request.service_names_to_s}")
  end

  def terminate(request)
    compose_cmd("stop #{request.service_names_to_s}")
    compose_cmd("rm -f #{request.service_names_to_s}")
    clean_cache(request)
  end

  #### Support Methods
  def deploy_type; :instance end

  # Generate
  def labels(base_labels, space_count)
    space_count ||= 6
    base_labels.select { |k, v| v }.map { |key, value| "#{key}: #{value}" }.join("\n#{' ' * space_count}")
  end

  def before_execute_on_target; switch! end

  def switch!
    Dir.chdir(target.exec_path) do
      FileUtils.rm_f('.env')
      FileUtils.ln_s(compose_file, '.env')
    end
    # TODO: This is specific to a Cnfs Backend project
    # Dir.chdir("#{target.deployment.root}/services") do
    #   FileUtils.rm_f('.env')
    #   FileUtils.ln_s("../#{target.write_path}", '.env')
    # end
    # unless config.platform.is_cnfs?
    #   Dir.chdir("#{deployment.root}/ros/services") do
    #     FileUtils.rm_f('.env')
    #     FileUtils.ln_s("../../#{write_path}", '.env')
    #   end
    # end
  end

  def compose_file; @compose_file ||= "#{runtime_path}/compose.env" end

  # TODO: taken from deploy command; is it needed/appropriate here?
  def set_compose_options
    @compose_options = ''
    if options.daemon or options.console or options.shell or options.attach
      @compose_options = '-d'
    end
    output.puts "compose options set to #{compose_options}" if options.verbose
  end


  # See: https://docs.docker.com/engine/reference/commandline/ps
  def services(format: '{{.Names}}', status: :running, **filters)
    @services ||= list_services(format: format, status: status, **filters)
  end

  def list_services(format:, status:, **filters)
    filter = filters.each_pair.map { |key, value| "--filter 'label=#{key}=#{value}'" }
    filter.append("--filter 'status=#{status}'") if status
    filter.append("--format '#{format}'") if format

    command_string = "docker ps #{filter.join(' ')}"
    controller.output.puts command_string if options.verbose
    out, err = controller.command(printer: :null).run(command_string)
    # binding.pry

    # TODO: _1 is assumed; there could be > 1
    out.split("\n").map{ |a| a.gsub("#{project_name}_", '').chomp('_1') }
  end


  def gem_cache_server
    return unless %x(docker ps).index('gem_server')
    host = RbConfig::CONFIG['host_os']
    return %x(ifconfig vboxnet1).split[7] if host =~ /darwin/
    %x(ip -o -4 addr show dev docker0).split[3].split('/')[0]
  end

  def database_check(service)
    return true unless service.respond_to?(:database_seed_commands)

    migration_file = "#{runtime_path}/#{service.name}-migrated"
    return true if File.exist?(migration_file) unless options.seed

    FileUtils.rm(migration_file) if File.exist?(migration_file)
    result = service.database_seed_commands.each do |command|
      if compose_cmd("run --rm #{service.name} #{command}")
        FileUtils.touch(migration_file)
      else
      #   errors.add(:database_check, stderr)
        break
      end
      true
    end
    result
  end

  def compose_cmd(cmd, never_capture = false)
    switch!
    hash = {}
    if gem_cache = gem_cache_server
      hash = { 'GEM_SERVER' => "http://#{gem_cache}:9292" }
    end
    system_cmd("docker-compose #{cmd}", hash, never_capture)
  end

  # def system_cmd(cmd, env = {}, options = {})
  #   controller.output.puts cmd if options.verbose
  #   system(env, cmd) unless options.noop
  # end

  # TODO: not necessary to pass options since controller is a reference to the command
  # which has the options
  def compose(service, command, options = {})
    cmd = ['docker-compose']
    cmd << (services.include?(service) ? 'exec' : 'run --rm')
    cmd.append(service).append(command)
    controller.output.puts(cmd.join(' ')) if options.verbose
    # cmd = TTY::Command.new(pty: true).run(cmd.join(' '))
    system(cmd.join(' '))
  end
end
