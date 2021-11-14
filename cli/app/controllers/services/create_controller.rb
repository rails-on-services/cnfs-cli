# frozen_string_literal: true

# Create a new service from a gem (angular, rails) into a repository
# To hook into this controller gems need to implement <Namespace>::Services::NewController
module Services
  class CreateController < Thor
    include CommandHelper

    # Activate common options
    # NOTE: No environment or namespace; All services are declared at the project scope
    # cnfs_class_options :repository, :source_repository
    cnfs_class_options :dry_run, :logging, :force

    private

    # Ensure a valid repository is specified; raise an error if not
    # class_before :set_repository
    # Other gems, e.g. rails, angular, etc. include their commands in this class
    # This method is available for those classes to invoke
    def invoke(generator, repo)
      generator.destination_root = repo.full_path
      generator.invoke_all
      binding.pry
    end
  end
end
