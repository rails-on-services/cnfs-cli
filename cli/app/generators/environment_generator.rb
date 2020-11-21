# frozen_string_literal: true

class EnvironmentGenerator < Thor::Group
  include Thor::Actions
  argument :name

  def generate_key
    key_file_path = Cnfs.user_root.join(Cnfs.config.name, 'config/environments', name, 'keys.yml')
    # binding.pry
    # TODO: Make the key generator or template under ../keys
    # template(views_path.join('keys.yml.erb'), key_file_path)
  end

  def generate_project_files
    inside(Cnfs.paths.config.join('environments')) do
      # empty_directory(name)
      # binding.pry
      # template(views_path.join('services.yml.erb'), "#{name}/services.yml")
      # template('environment.yml.erb', "#{name}.yml")
      template(views_path.join('templates/environment.yml.erb'), "#{name}.yml")
    end
  end

  private

  #   def another
  #     "
  #   # services: localstack, postgres, redis, wait, nginx
  #   # resources: postgres, vpc_with_db, storage
  #   blueprint: aws_instance
  #   dns_root_domain: localhost
  #   # config:
  #   #   # dns_sub_domain: development
  #   #   # lb_dns_hostnames: ['api']
  #   #   # root_domain_managed_in_route53: yes
  # "
  #   end

  def source_paths
    [views_path, views_path.join('templates')]
  end

  def views_path
    # @views_path ||= internal_path.join('../views/component/templates')
    @views_path ||= internal_path.join('environment')
  end

  def internal_path
    Pathname.new(__dir__)
  end
end
