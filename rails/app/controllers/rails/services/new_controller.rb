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
        desc 'rails NAME', 'Create a new CNFS service based on the Ruby on Rails Framework'
        # option :database, desc: 'Preconfigure for selected database (options: postgresql)',
        #   aliases: '-D', type: :string, default: 'postgresql'
        # option :test_with, desc: 'Testing framework',
        #   aliases: '-t', type: :string, default: 'rspec'
        # TODO: Add options that carry over to the rails plugin new command
        option :type, desc: 'The service type to generate, application or plugin',
          aliases: '-t', type: :string
        # option :gem, desc: 'Base this service on a CNFS compatible service gem from rubygems, e.g. cnfs-iam',
        #   aliases: '-g', type: :string
        # option :gem_source, desc: 'Source path to a gem in the project filesystem, e.g. ros/iam (used for development of source gem)',
        #   aliases: '-s', type: :string
        def rails(name)
          before_run
          type = options.type || Cnfs.repository.service_type
          raise Cnfs::Error, "Unknown service type #{type}" unless %w[application plugin].include?(type)

          binding.pry
          # if %w[iam cognito storage organization].include?(options.type)
          #   options = Thor::CoreExt::HashWithIndifferentAccess.new(options.merge(type: 'application', ))
          # TODO: options.gem and options.gem_sourcce are only valid if type is application
          generate(:rails, ['restogy', name])
        end

        # desc 'cnfs_rails', 'Add a CNFS service based on the Ruby on Rails Framework'
        # option :type, desc: 'The service type to generate: iam, cognito, storage, organization',
        #   aliases: '-t', type: :string
        # def cnfs_rails(name)
        #   return unless %w[iam cognito storage organization].include?(options.type)
        #   
        #   binding.pry
        #   # TODO: options.gem and options.gem_sourcce are only valid if type is application
        #   generate(:rails, ['restogy', name])
        # end

        # desc 'iam', 'Add the IAM service'
        # def iam(name = 'iam')
        #   generate(:rails, ['restogy', name])
        # end
      end
    end
  end
end

