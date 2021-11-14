# frozen_string_literal: true

# Create a new Angular service in a CNFS Angular repository; add an angular service configuration to the project
module Angular
  module Services
    module CreateController
      extend ActiveSupport::Concern

      included do
        desc 'angular NAME', 'Create a new Angular service in a CNFS Angular repository'
        # option :database, desc: 'Preconfigure for selected database (options: postgresql)',
        #   aliases: '-D', type: :string, default: 'postgresql'
        # option :test_with, desc: 'Testing framework',
        #   aliases: '-t', type: :string, default: 'rspec'
        # TODO: Add options that carry over to the rails plugin new command
        option :repository, desc: 'The repository in which to generate the service',
                            aliases: '-r', type: :string # , default: default_repository
        # option :type, desc: 'The service type to generate, application or plugin',
        #   aliases: '-t', type: :string, default: repo_options.service_type || 'application'
        # option :gem, desc: 'Base this service on a CNFS compatible service gem from rubygems, e.g. cnfs-iam',
        #   aliases: '-g', type: :string
        # option :gem_source, desc: 'Source path to a gem in the project filesystem, e.g. ros/iam (used for development of source gem)',
        #   aliases: '-s', type: :string
        def angular(name)
          # if %w[iam cognito storage organization].include?(options.type)
          #   options = Thor::CoreExt::HashWithIndifferentAccess.new(options.merge(type: 'application', ))
          # TODO: options.gem and options.gem_sourcce are only valid if type is application
          # generate(:rails, ['restogy', name])
        end
      end
    end
  end
end
