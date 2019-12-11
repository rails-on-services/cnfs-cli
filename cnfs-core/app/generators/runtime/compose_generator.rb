# frozen_string_literal: true

class Runtime::ComposeGenerator < GeneratorBase
  def env
    template('env.erb', target.runtime.compose_file)
  end

  private

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

  # def context_path; "#{relative_path}#{config.ros ? '/ros' : ''}" end

  # def relative_path; @relative_path ||= ('../' * values.path_for.to_s.split('/').size).chomp('/') end

  # def gid
  #   ext_info = OpenStruct.new
  #   if (RbConfig::CONFIG['host_os'] =~ /linux/ and Etc.getlogin)
  #     shell_info = Etc.getpwnam(Etc.getlogin)
  #     ext_info.puid = shell_info.uid
  #     ext_info.pgid = shell_info.gid
  #   end
  #   ext_info
  # end

  def views_path; Pathname.new(internal_path).join('../../views') end

  def internal_path; __dir__ end
end
