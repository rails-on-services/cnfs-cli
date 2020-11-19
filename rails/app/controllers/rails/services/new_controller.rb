# frozen_string_literal: true

# Create a new CNFS Rails service in a project's repository
# Add the service configuration to the project
module Rails
  module Services
    module NewController
      extend ActiveSupport::Concern

      included do
        # NOTE: All CNFS derived services come from the CNFS plugin which knows what the dependent
        # gem is and whether the CNFS repo is available locally so whether it should be mapped or not
        # TODO: Add options that carry over to the rails plugin new command
        desc 'rails NAME', 'Create a new CNFS service based on the Ruby on Rails Framework'
        # option :database, desc: 'Preconfigure for selected database (options: postgresql)',
        #   aliases: '-D', type: :string, default: 'postgresql'
        # option :test_with, desc: 'Testing framework',
        #   aliases: '-t', type: :string, default: 'rspec'
        # option :gem,        desc: 'Base this service on a CNFS compatible service gem from rubygems, e.g. cnfs-iam',
        #                     aliases: '-g', type: :string
        # option :gem_source, desc: 'Source path to a gem in the project filesystem, e.g. ros/iam (used for development of source gem)',
        #                     aliases: '-s', type: :string
        option :type,       desc: 'The service type to generate, application or plugin',
                            aliases: '-t', type: :string, default: Cnfs.repository&.service_type
        cnfs_options :force
        # TODO: Add before for type
        def rails(name)
          type = options.type || Cnfs.repository.service_type
          raise Cnfs::Error, "Unknown service type #{type}" unless %w[application plugin].include?(type)

          generator = Rails::ServiceGenerator.new([name], options)
          generator.destination_root = Cnfs.repository.path

          # TODO: Dir check does not take into account full_service_name
          service_path = "#{generator.destination_root}/services/#{name}"
          if Dir.exist?(service_path)
            raise Cnfs::Error, "service #{name} already exists" unless options.force
            FileUtils.rm_rf(service_path)
            # TODO: This also doesn't reverse the SDK
            # so it should run this with behvior revoke and then run again with invoke
          end

          generator.invoke_all
        end
      end
    end
  end
end
