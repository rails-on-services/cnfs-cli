# frozen_string_literal: true

module Main
  class VersionController
    attr_accessor :name, :options

    def initialize(name, options)
      @name = name
      @options = options
    end

    def execute
      pad = CnfsCli.plugins.keys.max_by(&:length).size + 10
      puts "Component#{' ' * (pad - 9)}Version"
      puts "cli_core#{' ' * (pad - 8)}#{Cnfs::VERSION}"
      CnfsCli.plugins.each do |namespace, plugin_class|
        print "#{namespace}#{' ' * (pad - namespace.length)}"
        puts plugin_class.plugin_lib::VERSION
      end
    end
  end
end
