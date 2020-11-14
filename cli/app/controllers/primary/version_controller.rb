# frozen_string_literal: true

module Primary
  class VersionController
    attr_accessor :name, :options

    def initialize(name, options)
      @name = name
      @options = options
    end

    def execute
      puts "Component\tVersion\ncore\t\t#{Cnfs::VERSION}"
      Cnfs.plugins.keys.sort.each do |namespace|
        puts "#{namespace}\t\t" + "Cnfs::Cli::#{namespace.to_s.classify}::VERSION".safe_constantize
      end
    end
  end
end
