# frozen_string_literal: true

module Generic
  module Services
    class AddController < Thor
      include CommandHelper

      def self.description
        'Add a generic service'
      end

      # Activate common options
      class_option :environment, desc: 'Target environment',
                                 aliases: '-e', type: :string
      class_option :namespace, desc: 'Target namespace',
                               aliases: '-n', type: :string
      cnfs_class_options :dry_run, :logging, :force

      desc 'localstack', 'Add a Localstack service'
      def localstack(name = 'localstack')
        generate('restogy', name, 'localstack')
      end

      desc 'nginx', 'Add a Nginx service'
      def nginx(name = 'nginx')
        generate('restogy', name, 'nginx')
      end

      desc 'postgres', 'Add a Postgres service'
      def postgres(name = 'postgres')
        generate('restogy', name, 'postgres')
      end

      desc 'redis', 'Add a Redis service'
      def redis(name = 'redis')
        generate('restogy', name, 'redis')
      end

      desc 'wait', 'Add a Wait service'
      def wait(name = 'wait')
        generate('restogy', name, 'wait')
      end

      private

      def generate(project, name, type)
        services_file = [options.environment, options.namespace, 'services.yml'].compact.join('/')
        generator = Generic::ServiceGenerator.new([project, name, type], options.merge(services_file: services_file))
        generator.destination_root = Cnfs.paths.config.join('environments')
        generator.invoke_all
      end
    end
  end
end
