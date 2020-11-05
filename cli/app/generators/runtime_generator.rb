# frozen_string_literal: true

class RuntimeGenerator < ApplicationGenerator
  attr_accessor :service

  # NOTE: Generate the environment files first b/c the manifest template will
  # look for the existence of those files
  def generate_service_environments
    Service.all.reject { |service| service.environment.empty? }.each do |service|
      file_name = application.write_path(path_type).join("#{service.name}.env")
      environment = Config::Options.new.merge!(service.environment)
      generated_files << template('../env.erb', file_name, env: environment)
    end
  end

  def invoke_parent_methods
    generate_entity_manifests
    remove_stale_files
  end

  private

  def proxy_services
    # services.select { |svc| svc.respond_to?(:profiles) && svc.profiles.include?('server') }
    application.selected_services.select { |svc| svc.config.dig(:profiles)&.include?('server') }
  end

  # Is a given service enabled?
  # def service_enabled?(name)
  #   application.selected_services.pluck(:name).include? name.to_s
  # end

  def entity_name
    :service
  end

  def entities
    application.selected_services
  end

  # Render template
  def generate
    template("#{entity_to_template}.yml.erb", "#{application.write_path(path_type)}/#{service.name}.yml")
  end

  def path_type
    :deployment
  end

  # Methods for all runtime templates
  def relative_path
    application.relative_path(path_type)
  end

  def template_types
    @template_types ||= application.selected_services.map { |service| entity_to_template(service).to_sym }.uniq
  end

  def version
    application.runtime.version
  end

  # Default space_count is for compose
  # Template is expected to pass in a hash for example for profile
  def labels(labels: {}, space_count: 6)
    application.runtime.labels(labels.merge(service: service.name)).map do |key, value|
      "\n#{' ' * space_count}#{key}: #{value}"
    end.join
  end

  def env_files(space_count = 6)
    @env_files ||= {}
    @env_files[service] ||= set_env_files.join("\n#{' ' * space_count}- ")
  end

  def set_env_files
    files = []
    # files << './application.env' if File.exist?(application.write_path(path_type).join('application.env'))
    files << "./#{service.name}.env" if File.exist?(application.write_path(path_type).join("#{service.name}.env"))
    files
  end
end
