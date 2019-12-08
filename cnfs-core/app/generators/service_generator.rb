# frozen_string_literal: true

class ServiceGenerator < GeneratorBase
  def env
    template('env.erb', "#{@write_path}/#{service.name}.env") if environment
  end

  def manifest
    template("service/#{service.name}/#{orchestrator}.yml.erb", "#{@write_path}/#{service.name}.yml")
  end

  private

  def depends_on; %w[localstack] end

  def pull_policy; 'Always' end

  def environment; service.environment; end
  def name; service.name; end

  def mount; target.config.mount end

  def orchestrator; target.runtime.name end

  def version; target.runtime.config.version end

  def expose_ports(port)
    port, proto = port.to_s.split('/')
    host_port = map_ports_to_host ? "#{port}:" : ''
    proto = proto ? "/#{proto}" : ''
    "\"#{host_port}#{port}#{proto}\""
  end

  def map_ports_to_host; false end

  def labels(space_count = nil)
    target.runtime.labels(base_labels, space_count)
  end

  # TODO: Are other labels needed at all?
  def base_labels
    %i[deployment target application layer service].each_with_object({}) do |type, hash|
      hash[type] = send(type).name
    end
  end

  # def labels
  #   {
  #     platform_name: values.config.name,
  #     platform_env: values.config.env,
  #     platform_profile: values.config.profile,
  #     platform_feature_set: values.config.feature_set,
  #     platform_partition: :application,
  #     platform_component: :backend,
  #     platform_resource: options.service
  #   }
  # end

  # TODO: Should be either services.env or platform.env
  def env_files; @env_files ||= ['../services.env'] end
end
