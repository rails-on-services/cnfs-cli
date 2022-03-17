# frozen_string_literal: true

require_relative '../extension/configuration'

module SolidSupport
  class Plugin
    def config() = @config ||= Configuration.new

    class Configuration < Extension::Configuration
    end
  end
end
