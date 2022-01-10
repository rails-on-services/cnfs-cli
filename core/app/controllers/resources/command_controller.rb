# frozen_string_literal: true

module Resources
  class CommandController < Thor
    include Concerns::CommandController

    cnfs_class_options :dry_run, :init, :quiet
    cnfs_class_options Cnfs.config.segments.keys

    desc 'console RESOURCE', 'Connect to a resource in the specified segment'
    def console(resource) = execute(resource: resource)
  end
end
