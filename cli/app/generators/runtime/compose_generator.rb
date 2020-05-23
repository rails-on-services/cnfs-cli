# frozen_string_literal: true

class Runtime::ComposeGenerator < RuntimeGenerator
  def generate_nginx_conf
    template('nginx.conf.erb', "#{context.write_path(:deployment)}/nginx.conf") if template_types.include?(:nginx)
  end

  def generate_compose_environment
    template('../env.erb', context.target.runtime.compose_file, env: compose_environment)
  end

  private

  def excluded_files
    ["#{context.write_path(path_type)}/nginx.conf"]
  end

  def mount
    # TODO: move to namespace
    context.target.mount
  end

  def expose_ports(port)
    port, proto = port.to_s.split('/')
    host_port = map_ports_to_host ? "#{port}:" : ''
    proto = proto ? "/#{proto}" : ''
    "\"#{host_port}#{port}#{proto}\""
  end

  def map_ports_to_host
    false
  end

  def compose_environment
    Config::Options.new(
      compose_file: Dir["#{context.write_path}/**/*.yml"].join(':'),
      compose_project_name: context.project_name,
      context_dir: '../../../../../../..',
      ros_context_dir: '../../../../../../../ros',
      image_repository: 'railsonservices',
      image_tag: '0.1.0-development-e7f7c0b',
      puid: '1001',
      pgid: '1002'
    )
  end
end
