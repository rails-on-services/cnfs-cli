# frozen_string_literal: true

require 'yaml'

class Native::Runtime < Runtime
  def before_execute_on_target
    switch!
  end

  # As we are running multiple overmind instances, we need to switch into the proper one
  def switch!
    @env = {}
  end

  def start
    response.add(exec: overmind("start #{procfile} #{background? ? '--daemonize' : ''}"))
  end

  def stop
    response.add(exec: overmind(background? ? 'quit' : 'kill'))
  end

  def overmind(command, type = 'application')
    cmd = [
      'overmind',
      command,
      socket(type)
    ].flatten.compact.join(' ')

    system(@env, cmd)
  end

  # rubocop:disable Lint/UnusedMethodArgument
  def services(status: :running, file_name: procfile_name)
    file = write_path(:manifests).join(file_name)

    YAML.load_file(file).keys
  end
  # rubocop:enable Lint/UnusedMethodArgument

  def service_names(status: :running)
    services(status: status).map { |a| a.gsub("#{project_name}_", '').chomp('_1') }
  end

  private

  def background?
    true
  end

  def socket(type = 'application')
    "--socket #{File.join(runtime_dir, project_name)}_#{type}.sock"
  end

  def runtime_dir
    %w[XDG_RUNTIME_DIR TMPDIR TMP TEMP .].each do |v|
      dir = ENV.fetch(v, nil)

      return Pathname.new(dir) if dir
    end
  end

  def procfile
    [
      '--procfile',
      write_path(:manifests).join(procfile_name)
    ].join ' '
  end

  def procfile_name
    'Procfile.woot'
  end
end
