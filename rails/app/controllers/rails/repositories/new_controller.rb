# frozen_string_literal: true

# Add a rails service configuration and optionally create a new service in a CNFS Rails repository
# To make this a registered subcommand class do this: class ServiceController < Thor
module Rails
  module Repositories
    module NewController
      extend ActiveSupport::Concern

      included do
        desc 'rails NAME', 'Add a CNFS compatible services repository based on the Ruby on Rails Framework'
        option :database, desc: 'Preconfigure for selected database (options: postgresql)',
                          aliases: '-D', type: :string, default: 'postgresql'
        option :test_with, desc: 'Testing framework',
                           aliases: '-t', type: :string, default: 'rspec'
        # TODO: Add options that carry over to the rails plugin new command
        def rails(name)
          binding.pry
          create_repository(:rails, name)
        end
      end
    end
  end
end
