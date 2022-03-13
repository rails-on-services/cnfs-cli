# frozen_string_literal: true

require 'tty-prompt'

require_relative 'solid_view/version'

module SolidView
  class Error < StandardError; end

  class << self
    attr_writer :logger

    def config() = @config ||= config_set

    def config_set
      config = ActiveSupport::OrderedOptions.new
      config
    end
  end
end

require_relative 'solid_view/extension' if defined? Hendrix

module SolidView
end
