# frozen_string_literal: true

module Cnfs
  class Context
    attr_accessor :cwd
    attr_accessor :config_parse_settings, :config_paths, :translations
    attr_reader :config

    def initialize(**options)
      # binding.pry
      options.each do |key, value|
        send("#{key}=".to_sym, value)
      end
      set_defaults
    end

    def paths
      # @paths ||= config.paths.each_with_object(OpenStruct.new) { |(k, v), os| os[k] = Pathname.new(v) }
      @paths ||= config.paths.each_with_object(OpenStruct.new) { |(k, v), os| os[k] = cwd.join(v) }
    end

    def reload
      @config = nil
      @cwd = nil
      @translations = nil
      set_defaults
    end

    def set_defaults
      @config_parse_settings ||= {}
      @translations ||= {}
      @config_paths ||= []
      @cwd ||= Pathname.new(Dir.pwd)
      self.class.cwd ||= cwd
      set_config
    end

    def config
      @config ||= set_config
    end

    def set_config
      config_parse_settings.each { |key, value| Config.send("#{key}=".to_sym, value) }
      base = [config_parse_settings[:env_prefix], config_parse_settings[:env_separator]].join
      translations.each do |short, long|
        ENV["#{base}#{long}".upcase] = ENV.delete("#{base}#{short}".upcase)
      end
      Config.use_env = true
      @config = Config.load_files(config_paths)
      Config.use_env = false
      @config.debug ||= 0
      # binding.pry
      @config
    end

    class << self
      attr_accessor :cwd
    end
  end
end
