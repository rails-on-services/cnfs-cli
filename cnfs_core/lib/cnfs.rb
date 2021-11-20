# frozen_string_literal: true

require 'config'
require 'tty-logger'
require 'xdg'

require_relative 'cnfs/utils'
require_relative 'cnfs/config_base'
require_relative 'cnfs/config'
require_relative 'cnfs/loader'

module Cnfs
  # class Error < StandardError; end

  class << self
    attr_accessor :plugin_root, :config, :configuration

    # rubocop:disable Metrics/AbcSize
    # Setup the core framework
    def setup(data_store: true, model_names: [])
      add_loader(name: :framework, path: Cnfs.plugin_root.gem_root.join('app'))
      # Create a loader for this gem's classes
      add_loader(name: :framework, path: Cnfs.gem_root.join('app'))

      Cnfs.plugin_root.plugins.each do |name, plugin_class|
        next unless (plugin = plugin_class.to_s.split('::').values_at(0, -1).join('::').safe_constantize)

        add_loader(name: :framework, path: plugin.gem_root.join('app'), notifier: plugin_class)
      end
      loaders.values.map(&:setup)

      Cnfs.data_store.add_models(model_names)
      Cnfs.data_store.setup if data_store
      Kernel.at_exit do
        Cnfs.logger.info(Cnfs.timers.map { |k, v| "\n#{k}:#{' ' * (30 - k.length)}#{v.round(2)}" }.join)
      end
    end
    # rubocop:enable Metrics/AbcSize

    def data_store
      @data_store ||= Cnfs::DataStore.new
    end

    def add_loader(name:, path:, notifier: nil)
      name = name.to_s
      loaders[name] ||= Cnfs::Loader.new(name: name, logger: logger)
      loaders[name].add_path(path)
      loaders[name].add_notifier(notifier)
      loaders[name]
    end

    def reload
      results = loaders.values.each_with_object([]) { |loader, ary| ary.append(loader.reload) }
      !results.include?(false)
    end

    def loaders
      @loaders ||= {}
    end

    # TODO: Multiple loggers
    def logger
      @logger ||= set_logger
    end

    def set_logger
      default_level = (config.logging || 'warn').to_sym
      level = ::TTY::Logger::LOG_TYPES.keys.include?(default_level) ? default_level : :warn
      ::TTY::Logger.new { |cfg| config.logging = cfg.level = level }
    end

    def timers
      @timers ||= {}
    end

    def require_deps(type = :minimum)
      with_timer('loading minimum dependencies') { require_relative 'cnfs/minimum_dependencies' }
      with_timer('loading core dependencies') { require_relative 'cnfs/dependencies' } if type.eql?(:all)
    end

    # Cnfs.plugin_modules(mod: CnfsCli, klass: RepositoriesController, only: [:aws, :rails])
    def plugin_modules_for(mod: self, klass:, only: [])
      plugins = only.empty? ? mod.plugins :  mod.plugins.select { |p| only.include?(p) }

      plugins.keys.each_with_object([]) do |mod_name, ary|
        mod_name = "#{mod_name.to_s.classify}::#{klass}"
        next unless (mod = mod_name.safe_constantize)

        # Ignore anything that is not an A/S::Concern, e.g. A/R STI classes
        ary.append(mod) if mod.is_a?(ActiveSupport::Concern)
      end
    end

    # NOTE: most of this moved to context. Is shift and caps needed?
    def reset
      @logger = nil
      # data_store.reload
      # @config = nil
      subscribers.each { |sub| ActiveSupport::Notifications.unsubscribe(sub.pattern) }
      # ARGV.shift # remove 'new'
      # @capabilities = nil
    end

    def gem_root
      @gem_root ||= Pathname.new(__dir__).join('..')
    end

    # Record any ActiveRecord pubsub subsribers
    def subscribers
      @subscribers ||= []
    end
  end
end
