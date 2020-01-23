# frozen_string_literal: true

require 'yaml'

class Runtime::Native < Runtime
  def before_execute_on_target
    switch!
  end

  # As we are running multiple overmind instances, we need to switch into the proper one
  def switch!
    @env = {}
  end

  def attach(type = :application)
    response.add(exec: overmind('connect', type)
  end

  def build
    true
  end

  def start
    types.each do |type|
      response.add(exec: overmind("start #{procfile(type)} #{background? ? '--daemonize' : ''}", type))
    end
  end

  def stop
    types.reverse.each do |type|
      response.add(exec: overmind(background? ? 'quit' : 'kill', type))
    end
  end

  def overmind(command, type = :application)
    raise "Unsupported type: #{type}" unless types.include?(type)

    cmd = [
      'overmind',
      command,
      socket(type)
    ].flatten.compact.join(' ')

    system(@env, cmd)
  end

  def services(status: :running, file_name: procfile_name)
    file = deployment_path.join(file_name)

    YAML.load_file(file).keys
  end

  def service_names(status: :running)
    services(status: status).map { |a| a.gsub("#{project_name}_", '').chomp('_1') }
  end

  private

  def types
    %i[infrastructure application]
  end

  def background?
    true
  end

  def socket(type = :application)
    "--socket #{File.join(runtime_dir, project_name)}_#{type}.sock"
  end

  def runtime_dir
    %w[XDG_RUNTIME_DIR TMPDIR TMP TEMP].each do |v|
      dir = ENV.fetch(v, nil)

      return Pathname.new(dir) if Dir.exist?(dir.to_s)
    end

    Pathname.new '.'
  end

  def procfile(type = :application)
    [
      '--procfile',
      deployment_path.join(procfile_name(type))
    ].join ' '
  end

  def procfile_name(type = :application)
    case type
    when :application
      'application.procfile'
    when :infrastructure
      'infrastructure.procfile'
    end
  end
end
