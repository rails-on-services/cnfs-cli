# frozen_string_literal: true

class RuntimeGenerator < ApplicationGenerator
  attr_accessor :service

  # NOTE: Generate the environment files first b/c the manifest template will
  # look for the existence of those files
  def generate_application_environment
    return unless (application_environment = deployment.to_env)

    generated_files << template('../env.erb',
                                outdir.join('application.env'),
                                env: application_environment)
  end

  def generate_service_environments
    services.each do |service|
      next unless (service_environment = service.to_env(target))

      generated_files << template('../env.erb',
                                  outdir.join("#{service.name}.env"),
                                  env: service_environment)
    end
  end

  def invoke_parent_methods
    generate_entity_manifests
    remove_stale_files
  end

  private

  def proxy_services
    # services.select { |svc| svc.respond_to?(:profiles) && svc.profiles.include?('server') }
    services.select { |svc| svc.config.dig(:profiles)&.include?('server') }
  end

  def expose_ports(start_port, _end_port = nil)
    port, proto = start_port.to_s.split('/')
    host_port = map_ports_to_host ? "#{port}:" : ''
    proto = proto ? "/#{proto}" : ''
    "\"#{host_port}#{port}#{proto}\""
  end

  def map_ports_to_host
    false
  end

  # Is a given service enabled?
  def service_enabled?(name)
    services.pluck(:name).include? name.to_s
  end

  def entity_name
    :service
  end

  def entities
    services
  end

  def outdir
    target.write_path path_type
  end

  def templates(list)
    list.each do |temp|
      template(temp + '.erb', File.join(outdir, temp))
    end
  end

  # Render template
  def generate
    template("#{entity_to_template}.yml.erb", "#{outdir}/#{service.name}.yml")
  end

  def path_type
    :deployment
  end

  # Methods for all runtime templates
  def relative_path
    @relative_path ||= Pathname.new('../' * outdir.to_s.split('/').size)
  end

  def template_types
    @template_types ||= services.map { |service| entity_to_template(service).to_sym }.uniq
  end

  def version
    target.runtime.version
  end

  def labels(space_count = nil)
    target.runtime.labels(base_labels, space_count)
  end

  def base_labels
    %i[deployment application target service].each_with_object({}) do |type, hash|
      hash[type] = send(type).name
    end
  end

  def env_files(space_count = 6)
    @env_files ||= {}
    @env_files[service] ||= set_env_files.join("\n#{' ' * space_count}- ")
  end

  def set_env_files
    files = []
    files << './application.env' if File.exist?(outdir.join('application.env'))
    files << "./#{service.name}.env" if File.exist?(outdir.join("#{service.name}.env"))
    files
  end
end
