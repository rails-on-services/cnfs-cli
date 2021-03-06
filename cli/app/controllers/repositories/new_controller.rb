# frozen_string_literal: true

module Repositories
  class NewController < Thor
    include CommandHelper
    include RepositoryHelper

    # Activate common options
    cnfs_class_options :source_repository
    cnfs_class_options :dry_run, :logging, :force

    private

    # Another gem includes its commands in this class, e.g. rails, angular, etc
    # This method is then available to those classes
    def invoke(generator, name)
      # TODO: Repository class should be handling everything but code generation
      Cnfs.paths.src.mkpath
      generator.destination_root = Cnfs.paths.src.join(name)
      generator.invoke_all
      update_config(name, url: '')
      # If this is the first repository added to the project then make it the default
      if Cnfs.config.repository.nil?
        o = Config.load_file('cnfs.yml')
        o.repository = name
        o.save
      end
    end
  end
end
