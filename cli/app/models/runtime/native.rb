# frozen_string_literal: true

require 'yaml'

class Runtime::Native < Runtime
  DEBUG = true

  def before_execute_on_target
    switch!
  end

  def switch!
    response.output.puts "Switching to #{target}"
  end

  def build
    true
  end

  def start
    response.add(exec: overmind('start', [procfile, background? ? '--daemonize' : '']), pty: !background?)
  end

  def stop
    response.add(exec: overmind(background? ? 'quit' : 'kill', []))
  end

  def restart(service = nil)
    stop.run! service
    start service
  end

  def logs
    response.add(exec: overmind('echo', []), pty: true)
  end

  def attach
    response.add(exec: overmind('connect', [ request.last_service_name ]))
  end

  def services(_status: :running)
    YAML.load_file(procfile).keys
  end

  def service_names(status: :running)
    services(status: status).map do |service|
      service.gsub("#{project_name}_", '').chomp('_1')
    end
  end

  private

  def overmind(command, args)
    cmd = [
      'overmind',
      command,
      args,
      socket
    ].flatten.compact.join(' ')
    env = overmind_env

    if DEBUG
      response.output.puts "CMD: #{cmd}"
      response.output.puts "ENV: #{env}"
    end

    system(env, cmd)
  end

  def overmind_env
    env = HashWithIndifferentAccess.new

    # env[:BASE_DIR] = ENV.fetch('BASE_DIR', Dir.pwd)
    env[:BASE_DIR] = Dir.pwd
    env[:DATA_DIR] = File.join(env[:BASE_DIR], 'var')
    env[:DB_DIR] = File.join(env[:DATA_DIR], 'db')
    env[:DB_PORT] = 5432.to_s
    env[:DB_SOCKET] = File.join(env[:DB_DIR], ".s.PGSQL.#{env[:DB_PORT]}")
    env[:REDIS_DIR] = File.join(env[:DATA_DIR], 'redis')
    env[:RUN_DIR] = ENV.fetch('XDG_RUNTIME_DIR', File.join(env[:DATA_DIR], 'run'))
    env[:LOG_DIR] = File.join(env[:DATA_DIR], 'log')
    env[:OVERMIND_SOCKET] = File.join(env[:RUN_DIR], 'overmind', File.basename(Dir.pwd) + '.sock')

    env[:PLATFORM__ENVIRONMENT__CONFIG__ROOT] = deployment_path.realpath.to_s

    env.select { |k,v| k.to_s =~ /_DIR$/ }.each_pair do |key, value|
      Dir.mkdir value unless Dir.exist? value
    end

    env
  end

  def background?
    !DEBUG
  end

  def socket
    "--socket #{File.join(runtime_dir, project_name)}.sock"
  end

  def runtime_dir
    %w[XDG_RUNTIME_DIR TMPDIR TMP TEMP].each do |v|
      dir = ENV.fetch(v, nil)

      return Pathname.new(dir) if Dir.exist?(dir.to_s)
    end

    Pathname.new '.'
  end

  def procfile
    [
      '--procfile',
      deployment_path.join('Procfile')
    ].join ' '
  end
end
