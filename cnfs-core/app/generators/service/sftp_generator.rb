# frozen_string_literal: true

class Service::SftpGenerator < ServiceGenerator

  def manifest
    template("service/sftp/#{orchestrator}.yml.erb", "#{write_path}/#{service.name}.yml")
  end

  # def environment
  #   return unless values.environment
  #   create_file("#{values.path_for}/#{options.service}.env", "#{values.environment.to_env.join("\n")}\n")
  #   env_files.append("../#{options.service}/#{options.service}.env")
  # end

  # def manifest
  #   # binding.pry
  #   template("#{orchestrator}.yml.erb", "#{values.path_for}/#{options.service}.yml")
  # end

  private

  # def internal_path; __FILE__ end

  # TODO: Get this from DNS
  def hostname; 'sftp.example.com' end
  def depends_on; %w[localstack] end

  def pull_policy; 'Always' end
  # def orchestrator; options.orchestrator end

  # def a_path; __dir__ end
  # def gem_root; Cnfs::Ext.gem_root end
end
