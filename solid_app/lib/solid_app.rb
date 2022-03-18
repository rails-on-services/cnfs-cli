# frozen_string_literal: true

# TODO: Isn't this already required by the Application? or what about when new?
# Test and make a note here if needed for new command
# require 'bundler/setup'

# require 'active_support'

require 'thor'
# require 'tty-logger'
require 'tty-prompt'
require 'tty-screen'
require 'tty-spinner'
require 'tty-table'
require 'tty-tree'
# require 'xdg'
# require 'zeitwerk'

require 'solid_support'

require_relative 'solid_app/version'

# application libs
require_relative 'solid_app/application'

require 'solid_record'

require_relative 'solid_app/application_command'
require_relative 'solid_app/application_controller'
require_relative 'solid_app/application_generator'
require_relative 'solid_app/console_controller'
require_relative 'solid_app/errors'
require_relative 'solid_app/loader'
require_relative 'solid_app/model_view'
require_relative 'solid_app/timer'
require_relative 'solid_app/version'
# binding.pry

require_relative 'solid_app/models/command'
require_relative 'solid_app/models/command_queue'
require_relative 'solid_app/models/download'
require_relative 'solid_app/models/extendable'
require_relative 'solid_app/models/git'

require_relative 'solid_app/platform'

module SolidApp
  class Error < StandardError; end

  class << self
    attr_writer :logger

    # def config() = @config ||= config_set

    def config_set
      config = ActiveSupport::OrderedOptions.new
      config.view_options = { help_color: :cyan }
      config
    end
  end
end

module SolidApp
end
