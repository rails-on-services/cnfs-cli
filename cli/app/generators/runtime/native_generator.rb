# frozen_string_literal: true

# Runtime for running native processes on host
class Runtime::NativeGenerator < RuntimeGenerator
  def generate_project_files
    outdir = target.write_path(:deployment)

    directory('files', outdir)

    Dir.chdir(outdir.join('libexec')) do
      symlink_map.each_pair do |src, dest|
        FileUtils.ln_s(dest, src.to_s)
      end
    end

    template('router.conf.erb', "#{outdir}/router.conf")
    template('Procfile.infra.erb', "#{outdir}/Procfile.infra")
    template('Procfile.erb', "#{outdir}/Procfile")
  end

  private

  def service_path(service)
    service&.config[:is_cnfs_service] ? '$CORE_PATH' : '$PLATFORM_PATH'
  end

  def service_profiles(service)
    (service.profiles || []) << 'spring'
  end

  def procfile_entry(service, profile, port = nil)
    name = service.name

    port = nil unless profile == 'server'

    [
      [name, profile].join('_') + ':',
      server_name_map[profile.to_sym],
      name,
      service_path(service),
      port
    ].compact.join ' '
  end

  def conditional_infra_services_map
    {
      postgres: '_postgres',
      fluentd: 'bundle exec fluentd --config ./fluent.conf',
      kafka: '_kafka',
      mail: '_mailcatcher',
      redis: '_redis'
    }
  end

  def infra_services_map
    {
      web: 'haproxy -- ./router.conf',
      yard: 'yard server --gems'
    }
  end

  def symlink_map
    { _kafka: '_docker', _localstack: '_docker', _sidekiq: '_rails', _spring: '_rails' }.freeze
  end

  def server_name_map
    { server: '_rails', worker: '_sidekiq', scheduler: '_scheduler', sqs_worker: '_sqs' }.freeze
  end

  def web_port
    5000
  end

  def web_port_increment
    10
  end
end
