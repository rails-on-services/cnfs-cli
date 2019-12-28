# frozen_string_literal: true

class RuntimeGenerator < GeneratorBase
  attr_accessor :service

  # NOTE: Generate the environment files first b/c the manifest template will look for the existence of those files
  def application_env
    template('../env.erb', target.write_path(:deployment).join('application.env'), { env: envs })
  end

  def services_env
    services.each do |service|
      next unless (env = service.environment.dig(:self))

      template('../env.erb', target.write_path(:deployment).join("#{service.name}.env"), { env: env })
    end
  end

  def manifest
    generated_files = services.each_with_object([]) do |service, files|
      @service = service
      files << generate
    end
    # FileUtils.rm(all_files - generated_files - excluded_files)
  rescue Thor::Error => e
    # TODO: add to errors array and have controller output the result
    puts e
    puts service.to_json
  end

  private

  def envs
    base_env = application.environment(target)
    [[target], resources, services].each_with_object(base_env) do |entities, environment|
      entities.each do |entity|
        next unless (env = entity.environment.dig(:application))
        environment.merge!(env.to_hash)
      end
    end
  end

  def relative_path; @relative_path ||= Pathname.new('../' * target.write_path(:deployment).to_s.split('/').size) end

  def service_types; @service_types ||= services.pluck(:type).compact.uniq.map{ |t| t.demodulize.underscore.to_sym } end

  def services; @services ||= (target.services + application.services) end

  def resources; @resources ||= (target.resources + application.resources) end

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

  def generate
    tmpl = service_to_template(service).to_s
    template("#{tmpl}.yml.erb", "#{target.write_path(path_type)}/#{[tmpl, service.name].uniq.join('-')}.yml")
  end

  def service_to_template(svc = service)
    return svc.template || svc.name unless (type = svc.type)
    key = type.demodulize.underscore.to_sym
    {}[key] || key
  end

  def path_type; :deployment end
end
