# frozen_string_literal: true

module Cnfs
  class Loader
    attr_reader :name, :loader
    attr_writer :load_paths

    # TODO: Catch a path overlap error
    def initialize(name:, path: nil, notifier: nil, logger: nil)
      @name = name
      @loader = Zeitwerk::Loader.new
      loader.logger = logger if logger
      add_path(path) if path
      add_notifier(notifier) if notifier
    end

    def add_path(root_path)
      return paths unless root_path.exist?

      root_path.children.select(&:directory?).select { |path| load_paths.include?(path.basename.to_s) }.each do |path|
        paths << path
      end
    end

    # Store all paths to be added to loader and ensure they are unique
    def paths
      @paths ||= Set.new
    end

    def load_paths
      @load_paths ||= %w[controllers generators helpers models views]
    end

    # Gems may want to set the loader's inflector and other work before classes are loaded
    def add_notifier(notifier)
      notifiers << notifier if notifier
    end

    def notifiers
      @notifiers ||= Set.new
    end

    # Zeitwerk loader methods
    def setup
      paths.each { |path| loader.push_dir(path) }
      notify(:before_loader_setup)
      loader.enable_reloading
      loader.setup
    end

    # TODO: Catch a reload error
    def reload
      result = loader.reload
      notify(:after_reload) if result
      text = result ? 'Reloaded' : 'Reload error on'
      loader.logger.debug("#{text} #{name}")
      result
    end

    def notify(method)
      notifiers.each do |notifier|
        notifier.send(method, loader) if notifier.respond_to?(method)
      end
    end
  end
end
