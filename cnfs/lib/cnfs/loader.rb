# frozen_string_literal: true

require 'zeitwerk'

module Cnfs
  class << self
    def add_loader(name:, path:, notifier: nil, logger: nil)
      name = name.to_s
      loaders[name] ||= Cnfs::Loader.new(name: name, logger: logger)
      loaders[name].add_path(path)
      loaders[name].add_notifier(notifier)
      loaders[name]
    end

    def loaders() = @loaders ||= {}

    def reload
      # Remove any A/R Cached Classes (e.g. STI classes)
      ActiveSupport::Dependencies::Reference.clear!
      results = loaders.values.each_with_object([]) { |loader, ary| ary.append(loader.reload) }
      !results.include?(false)
    end
  end

  class Loader
    attr_reader :name, :loader
    attr_writer :load_paths

    # TODO: Catch a path overlap error
    def initialize(name:, path: nil, notifier: nil, logger: nil)
      @name = name
      @loader = Zeitwerk::Loader.new
      # loader.logger = Logger.new($stderr)
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
    def paths() = @paths ||= Set.new

    def load_paths() = @load_paths ||= %w[controllers generators helpers models views]

    # Gems may want to set the loader's inflector and other work before classes are loaded
    def add_notifier(notifier)
      notifiers << notifier if notifier
    end

    def notifiers() = @notifiers ||= Set.new

    # Zeitwerk loader methods
    def setup
      paths.each do |path|
        loader.push_dir(path)
        next unless path.basename.to_s.eql?('generators')

        loader.ignore(path.join('**/files'))
        loader.ignore(path.join('**/templates'))
      end
      notify(:before_loader_setup)
      loader.enable_reloading
      loader.setup unless loader.instance_variable_get('@setup')
      loader.eager_load if defined? ::APP_ROOT
    end

    # Return list of autoloads for a specified plugin optionally prefixed with path
    # Example: Cnfs.loaders.first.last.select(Cnfs::Core, 'app/models')
    def select(plugin = Cnfs, path = '')
      loader.autoloads.select{ |k, v| k.start_with?(plugin.gem_root.join(path).to_s) }
    end

    # TODO: Catch a reload error
    def reload
      result = loader.reload
      loader.eager_load
      notify(:after_reload) if result
      text = result ? 'Reloaded' : 'Reload error on'
      loader.logger.debug(text, name) if loader.logger
      result
    end

    def unload() = loader.unload

    def notify(method)
      notifiers.each do |notifier|
        notifier.send(method, loader) if notifier.respond_to?(method)
      end
    end
  end
end
