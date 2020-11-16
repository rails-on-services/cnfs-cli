# frozen_string_literal: true

module Primary
  class VersionController
    attr_accessor :name, :options

    def initialize(name, options)
      @name = name
      @options = options
    end

    def execute
      pad = Cnfs.plugins.keys.max_by(&:length).size + 5
      puts "Component#{' ' * (pad - 9)}Version"
      puts "core#{' ' * (pad - 4)}#{Cnfs::VERSION}"
      Cnfs.plugins.keys.sort.each do |namespace|
        print "#{namespace}#{' ' * (pad - namespace.length)}"
        puts "Cnfs::Cli::#{namespace.to_s.classify}::VERSION".safe_constantize || 'Error loading'
      end
    end
  end
end
