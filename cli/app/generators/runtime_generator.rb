# frozen_string_literal: true

class RuntimeGenerator < ApplicationGenerator
  argument :runtime

  # NOTE: Generate the environment files first b/c the manifest template will
  # look for the existence of those files
  def environments
    context.services.select { |service| service.environment.any? }.each do |service|
      file_name = path.join("#{service.name}.env")
      binding.pry
      environment = Config::Options.new.merge!(service.environment)
      binding.pry
      generated_files << template('templates/env.erb', file_name, env: environment)
    end
  end

  def manifests
    name = nil
    context.services.each do |service|
      name = service.name
      # binding.pry
      generated_files << template(template_file(service), "#{path.join(service.name)}.yml")
    end
  rescue StandardError => e
    Cnfs.logger.warn("Error generating template for #{name}: #{e.message}")
    if Cnfs.config.dev
      msg = "#{e}\n#{e.backtrace}"
      # binding.pry
    end
  ensure
    remove_stale_files
  end

  private

  def template_file(service)
    [service.template, service.name, service.class.name.deconstantize, 'service'].each do |template_name|
      source_paths.each do |source_path|
        template_path = "templates/#{template_name}.yml.erb"
        return template_path if source_path.join(template_path).exist?
      end
    end
  end


  # List of services to be configured on the proxy server (nginx for compose)
  # TODO: Move this to an nginx service class in an RC
  def proxy_services() = context.services.select { |service| service.profiles.key?(:server) }

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
