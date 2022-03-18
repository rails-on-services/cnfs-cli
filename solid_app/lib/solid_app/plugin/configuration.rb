# frozen_string_literal: true

require_relative '../extension/configuration'

module SolidApp
  class Plugin
    def config() = @config ||= Configuration.new

    class Configuration < Extension::Configuration
    end
  end
end
