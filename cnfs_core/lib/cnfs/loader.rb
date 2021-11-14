# frozen_string_literal: true

module Cnfs
  class Loader
    attr_accessor :loader

    def initialize(logger: nil)
      @loader = Zeitwerk::Loader.new
      loader.logger = logger if logger
    end

    # Zeitwerk loader methods
    def setup
      ActiveSupport::Notifications.instrument 'before_loader_setup.cnfs', { loader: loader }
      autoload_dirs.each { |dir| loader.push_dir(dir) }
      loader.enable_reloading
      loader.setup
    end

    def autoload(mode: nil, paths: [])
      paths.each { |path| autoload_all(path) }
    end

    def autoload_dirs
      @autoload_dirs ||= []
    end

    def autoload_all(path)
      return [] unless path.join('app').exist?

      dirs = path.join('app').children.select(&:directory?).select { |m| default_load_paths.include?(m.split.last.to_s) }
      autoload_dirs.concat(dirs)
      dirs
    end

    def default_load_paths
      %w[controllers generators helpers models views]
    end

    def add_plugin_autoload_paths(values)
      values.each do |plugin_class|
        next unless (plugin = plugin_class.to_s.split('::').reject { |n| n.eql?('Plugins') }.join('::').safe_constantize)

        gem_load_paths = plugin.respond_to?(:load_paths) ? plugin.load_paths : %w[app]
        plugin_load_paths = plugin.respond_to?(:plugin_load_paths) ? plugin.plugin_load_paths : default_load_paths

        gem_load_paths.each do |load_path|
          load_path = plugin.gem_root.join(load_path)
          next unless load_path.exist?

          paths_to_load = load_path.children.select do |p|
            p.directory? && plugin_load_paths.include?(p.split.last.to_s)
          end
          autoload_dirs.concat(paths_to_load)
        end
      end
    end

    def reload
      loader.reload
    end
  end
end
