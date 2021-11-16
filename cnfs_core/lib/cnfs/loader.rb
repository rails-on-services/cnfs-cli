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
      self
    end

    def add_path(path)
      return paths unless path.exist?

      selected = path.children.select(&:directory?).select { |m| load_paths.include?(m.basename.to_s) }
      paths.concat(selected)
    end

    def paths
      @paths ||= []
    end

    def load_paths
      @load_paths ||= %w[controllers generators helpers models views]
    end

    def add_notifier(notifier)
      notifiers << notifier if notifier
    end

    def notifiers
      @notifiers ||= []
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
