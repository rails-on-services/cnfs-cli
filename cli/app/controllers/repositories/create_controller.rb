# frozen_string_literal: true

module Repositories
  class CreateController < Thor
    include CommandHelper

    # Activate common options
    # cnfs_class_options :source_repository
    cnfs_class_options :dry_run, :logging, :force

    private

    # Other gems, e.g. rails, angular, etc. include their commands in this class
    # This method is available for those classes to invoke
    def invoke(generator, repo)
      Cnfs.paths.src.mkpath
      generator.destination_root = repo.full_path
      generator.invoke_all
      # If this is the first repository added to the project then make it the default
      Cnfs.project.update(repository: repo) if Cnfs.project.repository.nil?
    end
  end
end
