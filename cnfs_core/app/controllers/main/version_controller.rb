# frozen_string_literal: true

module Main
  class VersionController
    attr_accessor :name, :options

    def initialize(name, options)
      @name = name
      @options = options
    end

    # rubocop:disable Metrics/AbcSize
    def execute
      name = Cnfs.plugin_root.name.underscore
      keys = Cnfs.plugin_root.plugins.keys.append(name)
      pad = keys.max_by(&:length).size + 10
      puts "Component#{' ' * (pad - 9)}Version"
      puts "#{name}#{' ' * (pad - name.length)}#{Cnfs.plugin_root::VERSION}"
      puts "cli_core#{' ' * (pad - 8)}#{Cnfs::VERSION}"
      Cnfs.plugin_root.plugins.each do |namespace, plugin_class|
        print "#{namespace}#{' ' * (pad - namespace.length)}"
        puts plugin_class.plugin_lib::VERSION
      end
    end
    # rubocop:enable Metrics/AbcSize
  end
end
