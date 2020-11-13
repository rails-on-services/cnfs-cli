# frozen_string_literal: true

class EnvironmentGenerator < Thor::Group
  include Thor::Actions
  argument :name

  def generate_key
    template(views_path.join('keys.yml.erb'), Cnfs.user_root.join(options.project_name, 'config/environments', name, 'keys.yml'))
  end

  def generate_project_files
    # binding.pry
    inside(Cnfs.paths.config.join('environments')) do
      empty_directory(name)
      create_file("#{name}/namespaces.yml", "---\n")
      template(views_path.join('services.yml.erb'), "#{name}/services.yml")
      inject_into_file('environments.yml') do
      "\n#{name}:
  key: #{name}
  type: Target::Instance
  runtime: compose
  infra_runtime: terraform
  provider: localstack
"
      end
    end
  end

  private

  def another
    "
  # services: localstack, postgres, redis, wait, nginx
  # resources: postgres, vpc_with_db, storage
  blueprint: aws_instance
  dns_root_domain: localhost
  # config:
  #   # dns_sub_domain: development
  #   # lb_dns_hostnames: ['api']
  #   # root_domain_managed_in_route53: yes
"
  end

  def source_paths
    [views_path] # , views_path.join('templates')]
  end

  def views_path
    @views_path ||= internal_path.join('../views/component/templates')
  end

  def internal_path
    Pathname.new(__dir__)
  end
end
