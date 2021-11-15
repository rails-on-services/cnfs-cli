# frozen_string_literal: true

module Cnfs
  class Loader
    attr_reader :name, :notifier, :loader

    # TODO: Catch a path overlap error
    def initialize(name:, notifier: nil, path: nil, logger: nil)
      @name = name
      @notifier = notifier
      add_path(path: path) if path
      @loader = Zeitwerk::Loader.new
      loader.logger = logger if logger
      self
    end

    # Zeitwerk loader methods
    def setup
      autoload_dirs.each { |dir| loader.push_dir(dir) }
      loader.enable_reloading
      notifier.before_loader_setup(loader) if notifier && notifier.respond_to?(:before_loader_setup)
      loader.setup
      self
    end

    def add_path(path:)
      autoload_all(path)
    end

    def autoload_all(path)
      return [] unless path.join('app').exist?

      dirs = path.join('app').children.select(&:directory?)
      dirs = dirs.select { |m| default_load_paths.include?(m.split.last.to_s) }
      autoload_dirs.concat(dirs)
      dirs
    end

    def autoload_dirs
      @autoload_dirs ||= []
    end

    def default_load_paths
      %w[controllers generators helpers models views]
    end

    # TODO: Catch a reload error
    def reload
      result = loader.reload
      text = result ? 'Reloaded' : 'Reload error on'
      Cnfs.logger.debug("#{text} #{name}")
      result
    end
  end
end
