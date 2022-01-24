# frozen_string_literal: true

require_relative 'boot'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require # (*Cnfs.groups)

module Blog
  module Concerns; end

  class Application < Hendrix::Application
    # Reference id for encryption keys and local file access
    config.project_id = '04ea04b3-1fd1-40a8-a0ca-cddfcc1b1f78'

    # The default value is :warn
    # config.logging = :warn

    # Comment out to remove the segment type from the console prompt
    config.cli.show_segment_name = true
    config.cli.show_segment_type = true

    # Comment out to ignore segment color settings
    config.cli.colorize = true

    # Example configurations for segments
    # basic colors: blue green purple magenta cyan yellow red white black
    config.segments.environment = { aliases: '-e', env: 'env', color:
      proc { |env| env.eql?('production') ? 'red' : env.eql?('staging') ? 'yellow' : 'green' } }
    config.segments.namespace = { aliases: '-n', env: 'ns', color: 'purple' }
    config.segments.stack = { aliases: '-s', color: 'cyan' }
    config.segments.target = { aliases: '-t', color: 'magenta' }

    config.paths.definitions = 'definitions'

    # config.solid_record.data_paths << { path: 'segments', path_map: 'components', recurse: true }
    config.solid_record.data_paths = [
      { path: 'segments', path_map: 'components', recurse: true, namespace: 'one_stack' }
    ]

    # config.asset_names = OneStack.asset_names

    # Configuration for the application, plugins, and extensions goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
  end
end
