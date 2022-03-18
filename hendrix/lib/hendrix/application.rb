# frozen_string_literal: true

module Hendrix
  class << self
    def application() = SolidApp.application

    def config() = SolidApp.config
  end

  class Application < SolidApp::Application
    config.before_initialize do |_config|
    end

    config.after_initialize do |_config|
    end

    class Configuration < SolidApp::Application::Configuration
    end
  end
end
