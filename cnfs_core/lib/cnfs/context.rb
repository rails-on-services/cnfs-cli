# frozen_string_literal: true

module Cnfs
  class Context
    attr_accessor :cwd
    attr_accessor :config_parse_settings, :config_paths, :translations
    attr_reader :config

    def initialize(**options)
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
      set_defaults
    end

    def set_defaults
      @config = nil
      @config_parse_settings ||= {}
      @translations ||= {}
      @config_paths ||= []
      @cwd ||= Pathname.new(Dir.pwd)
      self.class.cwd ||= cwd
    end

    def config
      @config ||= set_config
    end

    def set_config
      config_parse_settings.each { |key, value| Config.send("#{key}=".to_sym, value) }
      translations.each do |short, long|
        real_key = [config_parse_settings[:env_prefix], long].map(&:to_s).join(config_parse_settings[:env_separator]) 
        ENV[real_key.upcase] = ENV.delete(short.to_s.upcase)
      end
      Config.use_env = true
      @config = Config.load_files(config_paths)
      Config.use_env = false
      @config.debug ||= 0
      @config
    end

    class << self
      attr_accessor :cwd
    end
  end
end
