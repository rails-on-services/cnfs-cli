# frozen_string_literal: true

require_relative 'boot'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require # (*Cnfs.groups)

module Spec
  class Application < Cnfs::Application
    config.name = PROJECT_NAME

    # Reference id for storage of local files
    config.project_id = PROJECT_ID

    # The default value is :warn
    # config.logging = :warn

    # Example configurations for segments
    config.segments.environment = { aliases: '-e', color: 'yellow', env: 'env' }
    config.segments.namespace = { aliases: '-n', color: 'green', env: 'ns' }
    config.segments.segment = {}
    config.segments.stack = { aliases: '-s', color: 'green' }
    config.segments.target = { aliases: '-t', color: 'blue' }
  end
end
