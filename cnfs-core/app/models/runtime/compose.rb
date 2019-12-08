# frozen_string_literal: true

class Runtime::Compose < Runtime

  def build(services); "docker-compose build --parallel #{services.join(' ')}" end
  #      command(command_options).run!("docker-compose build --parallel #{requested_services.join(' ')}", cmd_options)
  #end

  def labels(base_labels, space_count)
    space_count ||= 6
    base_labels.select { |k, v| v }.map { |key, value| "#{key}: #{value}" }.join("\n#{' ' * space_count}")
  end

  # Switch is a CLI type of thing
  # TODO: deployment should have a method for platform_root
  def switch!
    Dir.chdir(deployment.root) do
      FileUtils.rm_f('.env')
      FileUtils.ln_s(config.platform.path_for(:runtime).join('compose/compose.env').to_s, '.env')
    end
    Dir.chdir("#{deployment.root}/services") do
      FileUtils.rm_f('.env')
      FileUtils.ln_s("../#{config.platform.path_for}/application/backend", '.env')
    end
    unless config.platform.is_cnfs?
      Dir.chdir("#{deployment.root}/ros/services") do
        FileUtils.rm_f('.env')
        FileUtils.ln_s("../../#{config.platform.path_for}/application/backend", '.env')
      end
    end
  end

  # taken from deploy command; is it needed/appropriate here?
    def set_compose_options
      @compose_options = ''
      if options.daemon or options.console or options.shell or options.attach
        @compose_options = '-d'
      end
      output.puts "compose options set to #{compose_options}" if options.verbose
    end

  # def application_compose_project_name; 'whistler_mounted' end
  # def compose_project_name
  #   binding.pry
  #   # "#{config.platform.config.name}_#{config.platform.env}"
  #   ''
  # end

  def compose_file; @compose_file ||= "#{compose_dir}/compose.env" end
  def compose_dir; "#{config.platform.path_for(:runtime)}/compose" end
  # =end

  # See: https://docs.docker.com/engine/reference/commandline/ps
  def services(format: '{{.Names}}', status: :running, **filters)
    @services ||= list_services(format: format, status: status, **filters)
  end

  def list_services(format:, status:, **filters)
    filter = filters.each_pair.map { |key, value| "--filter 'label=#{key}=#{value}'" }
    # filters.append("--filter 'label=stack.name=#{Settings.config.name}'")
    # filters.append("--filter 'label=application.component=#{application_component}'")
    # filters.append("--filter 'label=platform.feature_set=#{application.current_feature_set}'")
    filter.append("--filter 'status=#{status}'") if status
    filter.append("--format '#{format}'") if format

    command_string = "docker ps #{filter.join(' ')}"
    cmd.output.puts cmd if cmd.options.verbose
    out, err = cmd.command(printer: :null).run(command_string)
    binding.pry

    # TODO: _server is only one profile; fix
    # TODO: _1 is assumed; there could be > 1
    out.split("\n").map{ |a| a.gsub("#{deployment.platform_name}_", '').chomp('_1') }
  end

  # TODO: params
  def requested_services; params[:services] end

  def compose(service, command)
    cmd = ['docker-compose']
    cmd << (services.include?(service) ? 'exec' : 'run --rm')
    cmd.append(service).append(command)
    output.puts(cmd.join(' ')) if options.verbose
    # cmd = TTY::Command.new(pty: true).run(cmd.join(' '))
    system(cmd.join(' '))
  end
end
