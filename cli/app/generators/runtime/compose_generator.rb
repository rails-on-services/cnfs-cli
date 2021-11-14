# frozen_string_literal: true

class Runtime::ComposeGenerator < RuntimeGenerator
  # private
  def generate_nginx_conf
    # binding.pry
    template('nginx.conf.erb', "#{path}/nginx.conf") if template_types.include?(:nginx)
  end

  def generate_compose_environment
    template('env.erb', runtime.compose_file, env: compose_environment)
  end

  private

  def excluded_files
    ["#{path}/nginx.conf"]
  end

  def expose_ports(port = nil)
    return port unless port.nil?

    space_count = 6
    service.ports.each_with_object([]) do |entry, ary|
      case entry
      when Integer, String
        ary.append("\n#{' ' * space_count}- #{entry}")
      when Hash
        ary.append("\n#{' ' * space_count}- #{entry[:port]}")
      end
    end.join
    # 24222/udp
    # port, proto = port.to_s.split('/')
    # host_port = map_ports_to_host ? "#{port}:" : ''
    # proto = proto ? "/#{proto}" : ''
    # "\"#{host_port}#{port}#{proto}\""
  end

  def map_ports_to_host
    false
  end

  def compose_environment
    # TODO: remove all but compose_file and compose_project_name
    Config::Options.new(
      compose_file: Dir["#{path}/**/*.yml"].map { |f| f.gsub("#{CnfsCli.config.root}/", '') }.join(':'),
      compose_project_name: context.context_name,
      # context_dir: '../../../../../../..',
      # ros_context_dir: '../../../../../../../ros',
      # image_repository: 'railsonservices',
      # image_tag: '0.1.0-development-e7f7c0b',
      puid: '1001',
      pgid: '1002'
    )
  end
end
