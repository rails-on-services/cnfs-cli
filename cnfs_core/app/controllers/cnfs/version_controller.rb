# frozen_string_literal: true

module Cnfs
  class VersionController
    include Cnfs::Concerns::ExecController

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
      puts "Component#{' ' * (pad - 9)}Version", "#{name}#{' ' * (pad - name.length)}#{Cnfs.plugin_root::VERSION}"
      puts "cli_core#{' ' * (pad - 8)}#{Cnfs::VERSION}"
      Cnfs.plugin_root.plugins.sort.each do |namespace, plugin_class|
        print "#{namespace}#{' ' * (pad - namespace.length)}"
        lib_class = plugin_class.to_s.split('::').reject { |n| n.eql?('Plugins') }.join('::').safe_constantize
        puts lib_class::VERSION
      end
    end
    # rubocop:enable Metrics/AbcSize
  end
end
