# frozen_string_literal: true

# Emulate LittlePlugger's initialize process when in development mode
# by loading plugins from a directory path for development
# Plugins are loaded if found under the enclosing module's namespace
module CnfsPlugger
  # included when a class/module extends this module
  module ClassMethods
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/CyclomaticComplexity
    def initialize_plugins_from_path(gem_root, logger = nil)
      binding.pry if ENV['pry'] # 4
      plugin_path = LittlePlugger.default_plugin_path(self) # cnfs_core/plugins
      gem_root.join('..').children.select(&:directory?).each do |dir|
        plugin_dir = dir.join('lib', plugin_path)
        logger.debug("- #{plugin_path}") if logger
        logger.debug("* #{dir} - #{plugin_dir}") if logger
        unless plugin_dir.directory? && plugin_dir.children.any?
          # puts "* #{name} - #{plugin_dir}"
          next
        end

        $LOAD_PATH.unshift(dir.join('lib'))
        plugin_dir.children.each do |file|
          logger.debug("> #{name} - #{plugin_dir}") if logger
          class_name = file.split.last.to_s.delete_suffix('.rb')
          plugin_class = "#{plugin_path}/#{class_name}"
          require plugin_class
          next unless (klass = LittlePlugger.default_plugin_module(plugin_class))

          cmd = "initialize_#{class_name}"
          klass.send(cmd) if klass.respond_to?(cmd)
        end
      end
      plugins
    end
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize
  end

  class << self
    def extended(base)
      # puts "x: #{base} y"
      base.extend(ClassMethods)
    end
  end
end
