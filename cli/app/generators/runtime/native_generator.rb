# frozen_string_literal: true

# Runtime for running native processes on host
class Runtime::NativeGenerator < RuntimeGenerator
  def generate_project_files
    directory('files', outdir)

    symlink_map.each_pair do |dir, links|
      Dir.chdir(outdir.join(dir.to_s)) do
        links.each_pair do |src, dest|
          FileUtils.ln_sf(dest, src.to_s)
        end
      end
    end

    templates %w[router.conf Procfile]
  end

  private

  # Determine the path to a given service
  # TODO: does not belong here as it should not know anything about cnfs services
  def service_path(service)
    ENV.fetch(service.is_cnfs_service ? 'CORE_PATH' : 'PLATFORM_PATH')
  end

  # Add spring to the list of profiles
  # TODO: belongs in the rails plugin
  def service_profiles(service)
    (service.profiles || []) << 'spring'
  end

  # Create a Procfile entry for a given service
  # @param service [String] the service to process
  # @param profile [String] the service profile
  # @param port [Number] port or `nil`. Only needed for services that need to listen on a particular port
  # @return [String] a Procfile line
  def procfile_entry(service, profile, port = nil)
    name = service.name

    port = nil unless profile == 'server'

    [
      [name, profile].join('_') + ':',
      'bash',
      './libexec/' + server_name_map[profile.to_sym].to_s,
      name,
      service_path(service),
      port.to_s
    ].compact.join ' '
  end

  # Infrastructure services that may not be enabled
  def conditional_infra_services_map
    {
      fluentd: 'bundle exec fluentd --config ./fluentd.conf',
      haproxy: 'haproxy -- ./router.conf',
      kafka: 'bash ./libexec/_kafka',
      localstack: 'bash ./libexec/_localstack',
      mail: 'bash ./libexec/_mailcatcher',
      postgres: 'bash ./libexec/_postgres',
      redis: 'bash ./libexec/_redis'
    }
  end

  # Infrastructure services that are always enabled
  def infra_services_map
    {
      yard: 'yard server --gems'
    }
  end

  # Symlinks to create
  def symlink_map
    {
      libexec: {
        _elasticsearch: '_docker',
        _kafka: '_docker',
        _localstack: '_docker',
        _rabbitmq: '_docker',
        _scheduler: '_rails',
        _sidekiq: '_rails',
        _spring: '_rails'
      }
    }
  end

  def server_name_map
    {
      scheduler: '_scheduler',
      server: '_rails',
      spring: '_spring',
      sqs_worker: '_sqs',
      worker: '_sidekiq'
    }
  end

  # The starting port for application services
  def web_port
    5000
  end

  def web_port_increment
    10
  end
end
