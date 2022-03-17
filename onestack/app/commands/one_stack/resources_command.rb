# frozen_string_literal: true

module OneStack
  class ResourcesCommand < ApplicationCommand
    has_class_options :dry_run, :init, :quiet
    has_class_options OneStack.config.segments.keys

    desc 'console RESOURCE', 'Connect to a resource in the specified segment'
    def console(resource) = execute(resource: resource)
  end
end
