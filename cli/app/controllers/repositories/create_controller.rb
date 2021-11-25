# frozen_string_literal: true

module Repositories
  class CreateController < Thor
    include CommandHelper

    cnfs_class_options :dry_run, :logging, :force

    private

    # Gems, e.g. rails, angular, etc. and Repository Components include their commands in this class
    # This method is available for those classes to create the Repository record and invoke the generator
    def invoke(name, url, mod, opts = {})
      @mod = mod
      raise CnfsError, 'class not found' unless generator_class

      repo = mk_repo(name, url)
      raise CnfsError, 'Cannot create repositor record' unless repo.persisted?

      CnfsCli.config.paths.src.mkpath
      generator = generator_class.new([context, repo], options.merge(opts))

      generator.destination_root = repo.repo_path
      generator.invoke_all
      # If this is the first repository added to the project then make it the default
      # Cnfs.project.update(repository: repo) if Cnfs.project.repository.nil?
    end

    def generator_class() = @generator_class ||= "#{@mod}::RepositoryGenerator".classify.safe_constantize

    def mk_repo(name, url)
      context.component.repositories.create(name: name, url: url, type: "#{@mod}::Repository")
    end
  end
end
