# frozen_string_literal: true

module Hendrix
  class VersionController < ApplicationController
    # include Hendrix::Concerns::ExecController

    attr_accessor :name, :options

    def initialize(name, options)
      @name = name
      @options = options
    end

    # rubocop:disable Metrics/AbcSize
    def execute
      name = Hendrix.plugin_root.name.underscore
      keys = Hendrix.plugin_root.plugins.keys.append(name)
      pad = keys.max_by(&:length).size + 10
      puts "Component#{' ' * (pad - 9)}Version", "#{name}#{' ' * (pad - name.length)}#{Hendrix.plugin_root::VERSION}"
      puts "cli_core#{' ' * (pad - 8)}#{Hendrix::VERSION}"
      Hendrix.plugin_root.plugins.sort.each do |namespace, plugin_class|
        print "#{namespace}#{' ' * (pad - namespace.length)}"
        lib_class = plugin_class.to_s.split('::').reject { |n| n.eql?('Plugins') }.join('::').safe_constantize
        puts lib_class::VERSION
      end
    end
    # rubocop:enable Metrics/AbcSize
  end
end
