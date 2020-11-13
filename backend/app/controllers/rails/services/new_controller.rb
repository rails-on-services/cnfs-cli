# frozen_string_literal: true

# Add a rails service configuration and create a new service in a CNFS Rails repository
module Rails
  module Services
    module NewController
      extend ActiveSupport::Concern

      included do
        desc 'rails NAME', 'Create a new CNFS service based on the Ruby on Rails Framework'
        # option :database, desc: 'Preconfigure for selected database (options: postgresql)',
        #   aliases: '-D', type: :string, default: 'postgresql'
        # option :test_with, desc: 'Testing framework',
        #   aliases: '-t', type: :string, default: 'rspec'
        # TODO: Add options that carry over to the rails plugin new command
        option :repository, desc: 'The repository in which to generate the service',
          aliases: '-r', type: :string, default: default_repository
        option :type, desc: 'The service type to generate, application or plugin',
          aliases: '-t', type: :string, default: repo_options.service_type || 'application'
        option :gem, desc: 'Base this service on a CNFS compatible service gem from rubygems, e.g. cnfs-iam',
          aliases: '-g', type: :string
        option :gem_source, desc: 'Source path to a gem in the project filesystem, e.g. ros/iam (used for development of source gem)',
          aliases: '-s', type: :string
        def rails(name)
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

