# frozen_string_literal: true

module Core
  module Services
    class AddController < Thor
      include Cnfs::Options
      include ::Services::AddConcern

      def self.description
        'Add a CNFS core service'
      end

      # Activate common options
      cnfs_class_options :noop, :quiet, :verbose, :force

      desc 'iam', 'Add the IAM Service to the project'
      # TODO: If frontend repo exists then add to that; if backedn repo exists add to that also
      # TODO: Add the configuration for the service requested
      # Q: Is rails gem, cnfs repo or both responsible for the configuration files?
      def iam(name = nil)
        binding.pry
      end

      desc 'cognito', 'Add the Cognito Service to the project'
      def cognito(name = nil)
        binding.pry
      end

      desc 'storage', 'Add the Storage Service to the project'
      def storage(name = nil)
        binding.pry
      end

      desc 'comm', 'Add the Comm Service to the project'
      def comm(name = nil)
        binding.pry
      end

      desc 'organization', 'Add the Organization Service to the project'
      def organization(name = nil)
        binding.pry
      end
    end
  end
end
