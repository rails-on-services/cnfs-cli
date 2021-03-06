# frozen_string_literal: true

module Core
  module Services
    class NewController < Thor
      include CommandHelper

      # Label for Thor register command
      def self.description
        'Add a CNFS core service'
      end

      # Activate common options
      # NOTE: No environment or namespace; All services are declared at the project scope
      cnfs_class_options :repository, :dry_run, :logging

      # Validate that the requested repository is a rails repo and not the 'ros' repo
      class_before :validate_repository

      # TODO: If frontend repo exists then add to that; if backedn repo exists add to that also
      # TODO: Add the configuration for the service requested
      # Q: Is rails gem, cnfs repo or both responsible for the configuration files?
      %w[cognito comm iam organization storage].each do |method|
        desc "#{method} [NAME]", "Add the #{method.capitalize} Service to the project"
        define_method(method) do |name = method|
          # generate_service(name, method)
          generate_service_configs(name, method)
        end
      end

      private

      def generate_service(name, type)
        options.merge!(gem: "cnfs-#{type}", type: Cnfs.repository.service_type)
        if (cnfs_repo = Cnfs.repositories[:ros])
          repo_path = cnfs_repo.path.sub("#{Cnfs.paths.src}/", '')
          options.merge!(gem_source: type)
        end
        # generator = Rails::ServiceGenerator.new(['restogy', name], options)
        generator = Rails::ServiceGenerator.new([name], options)
        generator.destination_root = Cnfs.repository.path
        generator.invoke_all
      end

      def generate_service_configs(name, type)
        generator = Core::ServiceGenerator.new(['restogy', name, services_file_path], options)
        generator.destination_root = Cnfs.repository.path
        binding.pry
        generator.invoke_all
      end

      def validate_repository
        if not Cnfs.repository.type.eql?('Repository::Rails')
          raise Cnfs::Error, "Invalid repository type '#{Cnfs.repository.type}'." \
            " Valid repos:\n#{repo_list('rails', :reject, 'ros')}"
        elsif Cnfs.repository.namespace.eql?('ros')
          raise Cnfs::Error, "Cannot add a CNFS service to repository 'ros'." \
            " Valid repos:\n#{repo_list('rails', :reject, 'ros')}"
        end
      end

      def repo_list(type, action, *list)
        repos_matching(type).send(action) { |k, v| list.include?(k.to_s) }.map { |k, v| v.namespace }.join("\n")
      end

      def repos_matching(type)
        Cnfs.repositories.select { |name, config| config.type&.eql?(type) }
      end
    end
  end
end
