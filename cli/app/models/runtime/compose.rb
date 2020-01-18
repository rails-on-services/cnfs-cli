# frozen_string_literal: true

class Runtime::Compose < Runtime
  def attach
    response.add(exec: "docker attach #{project_name}_#{request.last_service_name}_1 --detach-keys='ctrl-f'", pty: true)
  end

  def build
    response.add(exec: compose("build --parallel #{request.service_names_to_s}"), env: compose_env)
  end

  # TODO: Get the command string to execute on the container from the service
  # def console; exec(request.last_service_name, :bash, true) end

  def copy(src, dest)
    service_name = src.index(':') ? src.split(':')[0] : dest.split(':')[0]
    response.add(exec: "docker cp #{src} #{dest}".gsub("#{service_name}:", "#{service_id(service_name)}:"))
  end

  def exec(service_name, command, pty)
    response.add(exec: compose(command, service_name), pty: pty)
  end

  def logs(service_name)
    compose_options = request.options.tail ? '-f' : ''
    response.add(exec: "docker logs #{compose_options} #{project_name}_#{service_name}_1", pty: request.options.tail)
  end

  def restart; stop.run!; refresh_services; start end

  def start
    database_check
    compose_options = request.options.foreground ? '' : '-d'
    response.add(exec: compose("up #{compose_options} #{request.service_names_to_s}"), env: compose_env)
  end

  def stop
    response.add(exec: compose("stop #{request.service_names_to_s}"))
  end

  def terminate; stop; clean end

  #### Support Methods

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

  def service_id(service_name); `docker-compose ps -q #{service_name}`.chomp end

  # See: https://docs.docker.com/engine/reference/commandline/ps
  def services(format: '{{.Names}}', status: :running, **filters)
    @services ||= list_services(format: format, status: status, **filters)
  end

  def service_names(status: :running)
    services(status: status).map{ |a| a.gsub("#{project_name}_", '').chomp('_1') }
  end

  def labels(base_labels, space_count)
    space_count ||= 6
    base_labels.select { |k, v| v }.map { |key, value| "#{key}: #{value}" }.join("\n#{' ' * space_count}")
  end

  private

  def refresh_services; @services = nil end

  def compose_env
    hash = {}
    hash.merge!({ 'GEM_SERVER' => "http://#{gem_cache_server}:9292" }) if gem_cache_server
    hash
  end

  def clean
    response.add(exec: compose("rm -f #{request.service_names_to_s}"))
    # clean_cache(request)
  end

  def deploy_type; :instance end

  # Generate
  # TODO: taken from deploy command; is it needed/appropriate here?
  def set_compose_options
    @compose_options = ''
    if request.options.daemon or request.options.console or request.options.shell or request.options.attach
      @compose_options = '-d'
    end
    output.puts "compose options set to #{compose_options}" if request.options.verbose
  end

  def list_services(format:, status:, **filters)
    filter = filters.each_pair.map { |key, value| "--filter 'label=#{key}=#{value}'" }
    filter.append("--filter 'status=#{status}'") if status
    filter.append("--filter 'name=#{project_name}'")
    filter.append("--format '#{format}'") if format

    command_string = "docker ps #{filter.join(' ')}"
    result = `#{command_string}`
    response.output.puts command_string if request.options.verbose
    result.split("\n").size > 1 ? result.split("\n") : []
  end


  def gem_cache_server
    return unless %x(docker ps).index('gem_server')

    host = RbConfig::CONFIG['host_os']
    # TODO: Make this configurable per user
    return %x(ifconfig vboxnet1).split[7] if host =~ /darwin/

    %x(ip -o -4 addr show dev docker0).split[3].split('/')[0]
  end

  def database_check
    request.services.each do |service|
      next unless service.respond_to?(:database_seed_commands)

      migration_file = "#{runtime_path}/#{service.name}-migrated"
      next unless !File.exist?(migration_file) or request.options.seed

      FileUtils.rm(migration_file) if File.exist?(migration_file)
      service.database_seed_commands.each do |command|
        response.add(exec: compose(command, service.name)).run!
        # TODO: refactor; this knows too much about what's going on in the response object
        if response.errors.size.zero?
          FileUtils.touch(migration_file)
        else
          break
        end
      end
    end
  end

  def compose(command, service_name = nil)
    cmd = ['docker-compose']
    cmd.append(service_names.include?(service_name) ? 'exec' : 'run --rm').append(service_name) if service_name
    cmd.append(command)
    cmd.join(' ')
  end
end
