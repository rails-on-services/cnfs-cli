# frozen_string_literal: true

require 'active_support'
require 'tty-prompt'
require 'tty-screen'
require 'tty-spinner'
require 'tty-table'
require 'tty-tree'

require_relative 'solid_view/version'
require_relative 'solid_view/model_view'

module SolidView
  class Error < StandardError; end

  class << self
    attr_writer :logger

    def config() = @config ||= config_set

    def config_set
      config = ActiveSupport::OrderedOptions.new
      config.view_options = { help_color: :cyan }
      config
    end
  end
end

require_relative 'solid_view/extension' if defined? Hendrix

module SolidView
end
