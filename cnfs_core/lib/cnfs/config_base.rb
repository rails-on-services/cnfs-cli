# frozen_string_literal: true

require 'thor'

module Cnfs
  class ConfigBase
    class << self
      attr_accessor :cwd
    end

    attr_accessor :name, :file_name, :cwd
    attr_accessor :config_parse_settings, :config_paths

    def initialize(**options)
      options.each { |key, value| send("#{key}=".to_sym, value) }
      return nil unless cwd && file_name

      @cwd = Pathname.new(cwd)
      self.class.cwd ||= cwd
    end

    def file
      root.join(file_name)
    end

    def root
      @root ||= @cwd.ascend { |path| break path if path.join(file_name).file? } || @cwd
    end

    # def file_name
    #   "#{name}.yml"
    # end

    def config_home
      @config_home ||= xdg.config_home.join(xdg_name)
    end

    def data_home
      @data_home ||= xdg.data_home.join(xdg_name)
    end

    def xdg_name
      name
    end

    def xdg
      @xdg ||= XDG::Environment.new
    end

    def config
      @config ||= set_config
    end

    def set_config
      before_set_config
      config_parse_settings.each { |key, value| ::Config.send("#{key}=".to_sym, value) }
      cfg = ::Config.load_files(config_paths)
      config_attributes.each { |attr| cfg.send("#{attr}=", send(attr)) }
      # TODO: Return a Thor Hash to return an immutable config
      # Thor::CoreExt::HashWithIndifferentAccess.new(cfg.to_hash)
      cfg
    end

    def before_set_config; end

    def config_attributes
      @config_attributes ||= %i[name cwd file root file_name config_home data_home]
    end

    def config_parse_settings
      @config_parse_settings ||= {}
    end

    def config_paths
      @config_paths ||= [root, config_home].map{ |path| path.join(file_name) }
    end

    def raw
      config_paths.select(&:exist?).each do |file|
        puts File.read(file)
      end
    end

    def paths
      @paths ||= set_paths
    end

    def set_paths
      hash = config.paths&.each { |name, path| config.paths[name] = root.join(path) }
      Thor::CoreExt::HashWithIndifferentAccess.new(hash)
    end

    ### END

    # def reload
    #   @config = nil
    #   @cwd = nil
    #   @translations = nil
    #   set_defaults
    # end
    #
    # def set_defaults
    #   @config_parse_settings ||= {}
    #   @translations ||= {}
    #   @config_paths ||= []
    #   @cwd ||= Pathname.new(Dir.pwd)
    #   self.class.root ||= root
    #   set_config
    # end
    #
    # def config
    #   @config ||= set_config
    # end
    #
    # def set_config
    #   config_parse_settings.each { |key, value| Config.send("#{key}=".to_sym, value) }
    #   base = [config_parse_settings[:env_prefix], config_parse_settings[:env_separator]].join
    #   # translations.each do |short, long|
    #   #   ENV["#{base}#{long}".upcase] = ENV.delete("#{base}#{short}".upcase)
    #   # end
    #   # Config.use_env = true
    #   @config = Config.load_files(config_paths)
    #   # Config.use_env = false
    #   @config.debug ||= 0
    #   # binding.pry
    #   @config
    # end
  end
end
