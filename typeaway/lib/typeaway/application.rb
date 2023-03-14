# frozen_string_literal: true

module Typeaway
  class << self
    def application() = SolidSupport.application

    def config() = SolidSupport.config
  end

  class Application < SolidSupport::Application
    config.before_initialize do |_config|
    end

    config.after_initialize do |_config|
    end

    class Configuration < SolidSupport::Application::Configuration
    end
  end
end
