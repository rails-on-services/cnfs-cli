# frozen_string_literal: true

class RuntimeGenerator < ApplicationGenerator
  attr_accessor :service

  # NOTE: Generate the environment files first b/c the manifest template will look for the existence of those files
  def generate_application_environment
    generated_files << template('../env.erb',
                                target.write_path(path_type).join('application.env'),
                                { env: application_environment })
  end

  def generate_service_environments
    services.each do |service|
      next unless (service_environment = service.environment.dig(:self))

      generated_files << template('../env.erb',
                                  target.write_path(path_type).join("#{service.name}.env"),
                                  { env: service_environment })
    end
  end

  def invoke_parent_methods
    generate_entity_manifests
    remove_stale_files
  end

  private

  def entity_name; :service end

  def entities; services end

  def application_environment
    base_env = application.to_env(:self, target)
    [[target], resources, services].each_with_object(base_env) do |env_providers, environment|
      env_providers.each do |env_provider|
        next unless (env = env_provider.to_env(:application, target)) # environment.dig(:application))

        environment.merge!(env.to_hash)
      end
    end
  end

  def generate
    template("#{entity_to_template}.yml.erb", "#{target.write_path(path_type)}/#{service.name}.yml")
  end

  def path_type; :deployment end

  # Methods for all runtime templates
  def relative_path; @relative_path ||= Pathname.new('../' * target.write_path(:deployment).to_s.split('/').size) end

  def template_types; @template_types ||= services.map{ |service| entity_to_template(service).to_sym }.uniq end

  def version; target.runtime.version end

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
    files << "./application.env" if File.exist?(target.write_path(:deployment).join('application.env'))
    files << "./#{service.name}.env" if File.exist?(target.write_path(:deployment).join("#{service.name}.env"))
    files
  end
end
