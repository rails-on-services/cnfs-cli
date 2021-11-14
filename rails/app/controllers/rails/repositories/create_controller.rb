# frozen_string_literal: true

# Add a rails service configuration and optionally create a new service in a CNFS Rails repository
# To make this a registered subcommand class do this: class ServiceController < Thor
module Rails
  module Repositories
    module CreateController
      extend ActiveSupport::Concern

      included do
        desc 'rails NAME', 'Create a CNFS compatible repository for services based on the Ruby on Rails Framework'
        option :database,  desc: 'Preconfigure for selected database (options: postgresql)',
                           aliases: '-D', type: :string, default: 'postgresql'
        option :test_with, desc: 'Testing framework',
                           aliases: '-t', type: :string, default: 'rspec'
        option :namespace, desc: 'How services will be named: project, repository, service',
                           type: :string, default: 'service'
        # TODO: Add options that carry over to the rails plugin new command
        def rails(name)
          # TODO: fix this issue with url being blank
          repo = ::Repository::Rails.create(name: name, url: 'h')
          generator = Rails::RepositoryGenerator.new([Cnfs.config.name, repo], options.merge(type: 'plugin')) # , source_repository: 'cnfs'))
          invoke(generator, repo)
        end
      end
    end
  end
end
