# frozen_string_literal: true

# Add a rails service configuration and optionally create a new service in a CNFS Rails repository
# To make this a registered subcommand class do this: class ServiceController < Thor
module Angular
  module Repositories
    module CreateController
      extend ActiveSupport::Concern

      included do
        desc 'angular NAME', 'Create a CNFS compatible repository for services based on the Angular Framework'
        def angular(name)
          create_repository(:angular, name)
        end
      end
    end
  end
end
