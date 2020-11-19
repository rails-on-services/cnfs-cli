# frozen_string_literal: true

module Generic
  module Services
    class AddController < Thor
      include Cnfs::Options

      def self.description
        'Add a generic service'
      end

      # Activate common options
      cnfs_class_options :noop, :quiet, :verbose, :force

      desc 'localstack', 'Add a Localstack service'
      def localstack(name = 'localstack')
        binding.pry
        generate(:generic, ['restogy', name, 'localstack'])
      end

      desc 'nginx', 'Add a Nginx service'
      def nginx(name = 'nginx')
        generate(:generic, ['restogy', name, 'nginx'])
      end

      desc 'postgres', 'Add a Postgres service'
      def postgres(name = 'postgres')
        generate(:generic, ['restogy', name, 'postgres'])
      end

      desc 'redis', 'Add a Redis service'
      def redis(name = 'redis')
        generate(:generic, ['restogy', name, 'redis'])
      end

      desc 'wait', 'Add a Wait service'
      def wait(name = 'wait')
        generate(:generic, ['restogy', name, 'wait'])
      end
    end
  end
end
