# frozen_string_literal: true

class RuntimeGenerator < ApplicationGenerator
  attr_accessor :service

  # NOTE: Generate the environment files first b/c the manifest template will
  # look for the existence of those files
  def generate_service_environments
    project.services.reject { |service| service.environment.empty? }.each do |service|
      file_name = write_path(path_type).join("#{service.name}.env")
      environment = Config::Options.new.merge!(service.environment)
      generated_files << template('env.erb', file_name, env: environment)
    end
  end

  def invoke_parent_methods
    generate_entity_manifests
    remove_stale_files
  end

  private

  def proxy_services
    project.services.select { |service| service.profiles.key?(:server) }
  end

  # Is a given service enabled?
  # def service_enabled?(name)
  #   application.selected_services.pluck(:name).include? name.to_s
  # end

  def entity_name
    :service
  end

  def entities
    project.services
  end

  # Render template
  def generate
    template("#{entity_to_template}.yml.erb", "#{write_path(path_type)}/#{service.name}.yml")
  end

  def path_type
    :manifests
  end

  def template_types
    @template_types ||= project.services.map { |service| entity_to_template(service).to_sym }.uniq
  end

  def version
    project.runtime.version
  end

  # Default space_count is for compose
  # Template is expected to pass in a hash for example for profile
  def labels(labels: {}, space_count: 6)
    project.runtime.labels(labels.merge(service: service.name)).map do |key, value|
      "\n#{' ' * space_count}#{key}: #{value}"
    end.join
  end

  def env_files(space_count = 6)
    @env_files ||= {}
    @env_files[service] ||= set_env_files.join("\n#{' ' * space_count}- ")
  end

  def set_env_files
    files = []
    files << "./#{service.name}.env" if File.exist?(write_path(path_type).join("#{service.name}.env"))
    files
  end
end
