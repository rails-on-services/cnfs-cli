# frozen_string_literal: true

module Cnfs
  class Providers
    attr_accessor :settings, :providers

    def initialize(settings)
      settings.each_pair do |name, config|
        klass = "Cnfs::Providers::#{config.service.capitalize}"
        providers[name] = instance_eval(klass).new(config)
      end
    end

    def providers; @providers ||= Config::Options.new end
  end

  class Providers::Aws
    attr_accessor :credentials, :resources
    def initialize(settings)
      @credentials = settings.credentials
      @resources = settings.resources
    end
  end

  class Providers::Gcp
    attr_accessor :credentials, :resources
    def initialize(settings)
      @credentials = settings.credentials
      @resources = settings.resources
    end
  end

  class Providers::Azure
    attr_accessor :credentials, :resources
    def initialize(settings)
      @credentials = settings.credentials
      @resources = settings.resources
    end
  end
end
