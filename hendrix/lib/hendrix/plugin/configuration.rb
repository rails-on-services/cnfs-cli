# frozen_string_literal: true

require_relative '../extension/configuration'

module Hendrix
  class Plugin
    def config() = @config ||= Configuration.new

    class Configuration < Hendrix::Extension::Configuration
    end
  end
end
