# frozen_string_literal: true

require_relative 'boot'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require # (*.groups)

module Spec
  module Concerns; end
  class Application < OneStack::Application
    # Reference id for encryption keys and local file access
    config.project_id = '3273b2fc-ff9c-4d64-8835-34ee3328ad68'

    # initializer 'based' do |app|
      # binding.pry
    # end

    # The default value is :warn
    # config.logging = :warn

    # Comment out to remove the segment name and/or type from the console prompt
    # Use the pwd command to show the full path
    config.cli.show_segment_name = true
    config.cli.show_segment_type = true

    # Comment out to ignore segment color settings
    config.cli.colorize = true
    config.paths.data = 'data'

    # Example configurations for segments
    # basic colors: blue green purple magenta cyan yellow red white black
    config.segments.environment = { aliases: '-e', env: 'env', color:
      Proc.new { |env| env.eql?('production') ? 'red' : env.eql?('staging') ? 'yellow' : 'green' } }
    config.segments.namespace = { aliases: '-n', env: 'ns', color: 'purple' }
    config.segments.stack = { aliases: '-s', color: 'cyan' }
    config.segments.target = { aliases: '-t', color: 'magenta' }

    config.solid_record.sandbox = true
    config.solid_record.namespace = :one_stack
    # config.solid_record.load_paths = [
      # { path: 'config/segment.yml', model_type: 'OneStack::SegmentRoot' },
      # { path: 'segments', owner: -> { OneStack::SegmentRoot.first } }
    # ]

    # Configuration for the application, plugins, and extensions goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
  end
end
