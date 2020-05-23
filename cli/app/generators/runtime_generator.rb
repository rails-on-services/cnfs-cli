# frozen_string_literal: true

class RuntimeGenerator < ApplicationGenerator
  attr_accessor :service

  # NOTE: Generate the environment files first b/c the manifest template will
  # look for the existence of those files
  def generate_application_environment
    return unless (application_environment = context.deployment.to_env)

    generated_files << template('../env.erb',
                                context.write_path(path_type).join('application.env'),
                                env: application_environment)
  end

  def generate_service_environments
    selected_services.each do |service|
      next unless (service_environment = service.to_env(context))

      generated_files << template('../env.erb',
                                  context.write_path(path_type).join("#{service.name}.env"),
                                  env: service_environment)
    end
  end

  def selected_services
    context.application.services + context.target.services
  end

  def invoke_parent_methods
    generate_entity_manifests
    remove_stale_files
  end

  private

  def proxy_services
    # services.select { |svc| svc.respond_to?(:profiles) && svc.profiles.include?('server') }
    selected_services.select { |svc| svc.config.dig(:profiles)&.include?('server') }
  end

  # Is a given service enabled?
  def service_enabled?(name)
    selected_services.pluck(:name).include? name.to_s
  end

  def entity_name
    :service
  end

  def entities
    selected_services
  end

  # Render template
  def generate
    # binding.pry
    template("#{entity_to_template}.yml.erb", "#{context.write_path(path_type)}/#{service.name}.yml")
  end

  def path_type
    :deployment
  end

  # Methods for all runtime templates
  def relative_path
    @relative_path ||= Pathname.new('../' * relative_dirs_to_application_root)
  end

  def relative_dirs_to_application_root
    context.write_path(path_type).to_s.gsub(Cnfs.application.root.to_s, '').split('/').size - 1
  end

  def template_types
    @template_types ||= selected_services.map { |service| entity_to_template(service).to_sym }.uniq
  end

  def version
    context.target.runtime.version
  end

  def labels(space_count = nil)
    context.target.runtime.labels(base_labels, space_count)
  end

  def base_labels
    # %i[deployment application target service].each_with_object({}) do |type, hash|
    %i[target namespace application ].each_with_object({}) do |type, hash|
      hash[type] = context.send(type).name
    end
  end

  def env_files(space_count = 6)
    @env_files ||= {}
    @env_files[service] ||= set_env_files.join("\n#{' ' * space_count}- ")
  end

  def set_env_files
    files = []
    files << './application.env' if File.exist?(context.write_path(path_type).join('application.env'))
    files << "./#{service.name}.env" if File.exist?(context.write_path(path_type).join("#{service.name}.env"))
    files
  end
end
