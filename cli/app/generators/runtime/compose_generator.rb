# frozen_string_literal: true

class Runtime::ComposeGenerator < RuntimeGenerator
  def generate_nginx_conf
    template('nginx.conf.erb', "#{target.write_path(:deployment)}/nginx.conf") if template_types.include?(:nginx)
  end

  def generate_compose_environment
    template('../env.erb', target.runtime.compose_file, env: compose_environment)
  end

  private

  def excluded_files
    ["#{target.write_path(path_type)}/nginx.conf"]
  end

  def mount
    target.mount
  end

  def compose_environment
    Config::Options.new(
      compose_file: Dir["#{target.write_path}/**/*.yml"].join(':'),
      compose_project_name: target.runtime.project_name,
      context_dir: '../../../../../../..',
      ros_context_dir: '../../../../../../../ros',
      image_repository: 'railsonservices',
      image_tag: '0.1.0-development-e7f7c0b',
      puid: '1001',
      pgid: '1002'
    )
  end
end
