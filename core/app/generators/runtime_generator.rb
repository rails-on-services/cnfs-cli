# frozen_string_literal: true

class RuntimeGenerator < Cnfs::ApplicationGenerator
  argument :runtime

  # NOTE: Generate the environment files first b/c the manifest template will
  # look for the existence of those files
  def environments
    context.services.select { |service| service.environment.any? }.each do |service|
      file_name = path.join("#{service.name}.env")
      binding.pry
      # TODO: remove Config::Options
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
    if CnfsCli.config.dev
      msg = "#{e}\n#{e.backtrace}"
      # binding.pry
    end
  ensure
    remove_stale_files
  end

  private

  # All content comes from Repository and Project Components so source paths reflect that
  # TODO: This probably needs to be further filtered based on the blueprint in the case of Provisoners
  # and by Resource? in the case of Runtimes
  # In fact this may need to be refactored from a global CnfsCli registry to a component hierarchy based
  def source_paths
    @source_paths ||= CnfsCli.loaders.values.map { |path| path.join('generators', generator_type) }.select(&:exist?)
  end

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
    files.append("./#{service.name}.env") if path.join("#{service.name}.env").exist?
    files
  end
end
