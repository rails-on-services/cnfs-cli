# frozen_string_literal: true

require_relative 'boot'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require # (*Cnfs.groups)

module Spec
  class Application < Hendrix::Application
    # Reference id for encryption keys and local file access
    config.project_id = '3273b2fc-ff9c-4d64-8835-34ee3328ad68'
  end
end
