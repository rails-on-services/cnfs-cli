# frozen_string_literal: true

class ComposeGenerator < RuntimeGenerator
  def nginx_conf
    template('nginx.conf.erb', "#{target.write_path(:deployment)}/nginx.conf") if service_types.include?(:nginx)
  end

  def fluentd_log_dir
    return unless behavior.eql?(:invoke) and service_types.include?(:fluentd)

    fluentd_dir = "#{target.write_path(:runtime)}/fluentd"
    empty_directory("#{fluentd_dir}/log")
    FileUtils.chmod('+w', "#{fluentd_dir}/log")
  end

  def compose_env
    template('../env.erb', target.runtime.compose_file, { env: environment })
  end

  private

  def nginx_services
    services.select{ |s| s.profiles.include? 'server' if s.respond_to?(:profiles) }.map(&:name)
  end

  def mount; target.mount end

  def expose_ports(port)
    port, proto = port.to_s.split('/')
    host_port = map_ports_to_host ? "#{port}:" : ''
    proto = proto ? "/#{proto}" : ''
    "\"#{host_port}#{port}#{proto}\""
  end

  def map_ports_to_host; false end

  def environment
    Config::Options.new({
      compose_file: Dir["#{target.write_path}/**/*.yml"].join(':'),
      compose_project_name: target.runtime.project_name,
      context_dir: '../../../../../../..',
      ros_context_dir: '../../../../../../../ros',
      image_repository: 'railsonservices',
      image_tag: '0.1.0-development-e7f7c0b',
      puid: '1001',
      pgid: '1002'
    })
  end

  # def gid
  #   ext_info = OpenStruct.new
  #   if (RbConfig::CONFIG['host_os'] =~ /linux/ and Etc.getlogin)
  #     shell_info = Etc.getpwnam(Etc.getlogin)
  #     ext_info.puid = shell_info.uid
  #     ext_info.pgid = shell_info.gid
  #   end
  #   ext_info
  # end
end
