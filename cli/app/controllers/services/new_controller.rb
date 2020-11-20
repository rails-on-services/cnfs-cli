# frozen_string_literal: true

# Create a new service from a gem (angular, rails) into a repository
# To hook into this controller gems need to implement <Namespace>::Services::NewController
module Services
  class NewController < Thor
    include CommandHelper

    # Activate common options
    # NOTE: No environment or namespace; All services are declared at the project scope
    cnfs_class_options :repository, :source_repository, :noop, :quiet, :verbose

    # Ensure a valid repository is specified; raise an error if not
    class_before :set_repository
  end
end
