# frozen_string_literal: true

class RuntimeGenerator < ApplicationGenerator
  attr_accessor :service

  # NOTE: Generate the environment files first b/c the manifest template will
  # look for the existence of those files
  def generate_service_environments
    context.services.reject { |service| service.environment.empty? }.each do |service|
      file_name = path.join("#{service.name}.env")
      environment = Config::Options.new.merge!(service.environment)
      generated_files << template('env.erb', file_name, env: environment)
    end
  end

  def generate_entity_manifests
    context.services.each do |service_obj|
      @service = service_obj
      generated_files << template("#{entity_to_template(service)}.yml.erb", "#{path}/#{service.name}.yml")
    end
  rescue StandardError => e
    if Cnfs.config.dev
      msg = "#{e}\n#{e.backtrace}"
      # binding.pry
    end
    # TODO: add to errors array and have controller output the result
    raise Cnfs::Error, "\nError generating template for #{@service.name}: #{msg}"
  ensure
    remove_stale_files
  end

  private

  def entity_to_template(entity = nil)
    entity ||= instance_variable_get("@#{entity_name}")
    # TODO: The entity should reutrn the template name rather than being so clever
    key = entity.template || entity.type&.underscore&.split('/')&.shift || entity.name
    entity_template_map[key.to_sym] || key
  end

  def entity_template_map
    {}
  end

  # Used by the ApplicationGenerator#plugin_paths
  def caller_path() = 'runtime'

  # List of services to be configured on the proxy server (nginx for compose)
  def proxy_services
    context.services.select { |service| service.profiles.key?(:server) }
  end

  def template_types
    @template_types ||= context.services.map { |service| entity_to_template(service).to_sym }.uniq
  end

  def version
    runtime.version
  end

  # Default space_count is for compose
  # Template is expected to pass in a hash for example for profile
  def labels(labels: {}, space_count: 6)
    context.labels.merge(labels).merge(service: service.name).map do |key, value|
      "\n#{' ' * space_count}#{key}: #{value}"
    end.join
  end

  def env_files(space_count = 6)
    @env_files ||= {}
    @env_files[service] ||= set_env_files.join("\n#{' ' * space_count}- ")
  end

  def set_env_files
    files = []
    files << "./#{service.name}.env" if File.exist?(path.join("#{service.name}.env"))
    files
  end

  # Used by all runtime templates; Returns a path relative from the write path to the project root
  # Example: relative_path(:manifests) # => #<Pathname:../../../..>
  def relative_path(path_type = :manifests)
    context.path(from: path_type)
  end

  def path(to: :manifests)
    context.path(to: to)
  end
end
