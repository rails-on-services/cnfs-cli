# frozen_string_literal: true

# Creates a new postgres service in the requested environment/namespace
module Generic
  class ServiceGenerator < Thor::Group
    include Thor::Actions
    argument :project_name
    argument :name
    argument :type

    def generate
      # binding.pry
      # FileUtils.touch(options.services_file)
      content = if File.exist?(template_path)
                  ERB.new(File.read(template_path)).result(binding)
                else
                  send(type)
                end
      binding.pry
      if File.exist?(options.services_file)
        append_to_file(options.services_file, content)
        # When revoked, the above line will subtract content; if the file is now empty the next line will remove it
        create_file(options.services_file) if behavior.eql?(:revoke) && File.size(options.services_file).zero?
      else
        create_file(options.services_file, content)
      end
    end

    private

    def template_path
      Pathname.new(__dir__).join('templates', "#{type}.yml.erb")
    end

    # def source_paths
    #   [Pathname.new(__dir__).join('templates')]
    # end

    def localstack
      "\n#{name}:\n  template: localstack\n  config:\n    image: localstack/localstack\n" \
        "    ports:\n     - { port: 4572, wait: yes }\n  environment:\n    services: s3:4572,lambda:4574,sns:4575,sqs:4576\n" \
        "    port_web_ui: 8080\n    debug: s3\n    hostname: localstack\n    hostname_external: localstack\n"
    end

    def nginx
      "\n#{name}:\n  template: nginx\n  config:\n    image: nginx\n"
    end

    def postgres
      "\n#{name}:\n  template: postgres\n  config:\n    ports:\n      - { port: 5432, wait: yes }\n  environment:\n" \
        "    postgres_user: admin\n    postgres_password: admin\n    postgres_db: postgres\n"
    end

    def redis
      "\n#{name}:\n  template: redis\n  config:\n    shell_command: sh\n    ports:\n      - { port: 6379, wait: yes }\n"
    end

    def wait
      "\n#{name}:\n  template: wait\n  tags: infra\n"
    end
  end
end
