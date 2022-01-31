# frozen_string_literal: true

# Lyrics provide the core of the Framework
# config and inline initializers

module Hendrix
  class << self
    def lyrics() = @lyrics ||= {}

    # Record initializers to be run after the application has loaded
    def initializers() = @initializers ||= []

      # # Call these things in order
      # def boot
      #   before_configuration.each(&:call)
      #   before_initialize.each(&:call)
      #   before_eager_load.each(&:call)
      #   # TODO: Call the loaders; Remove the call from app_loader
      #   after_initialize.each(&:call)
      # end
      #

    def run_initializers
      lyrics.each do |name, plugin|
        # binding.pry
        initializers.select{ |init| init[:name].eql?(plugin.to_s) }.each { |init| init[:block].call(Hendrix.config) }
        plugin.initializer_files.each { |file| require file }
      end
      # binding.pry
    end
  end

  class Lyric
    ABSTRACT_LYRICS = %w(Hnedrix::Lyric Hendrix::Tune Hendrix::Application)

    class << self
      delegate :config, to: :instance

      def abstract_lyric?() = ABSTRACT_LYRICS.include?(name)

      def instance() = @instance ||= new

      def initializer_files() = initializers_path.exist? ? initializers_path.glob('**/*.rb') : []

      def initializers_path() = config_path.join('initializers')

      def config_path() = gem_root.join('config')

      def app_path() = gem_root.join('app')

      def root() = gem_root

      # binding.pry

      # Called one or more times by subclasses to execute a block of code after application initialization
      def initializer(init_name, &block)
        # binding.pry
        yield config
        Hendrix.initializers.append({ name: name, init_name: init_name, block: block })
      end


      def inherited(base)
        name = name_from_base(base)
        return if base.to_s.eql?('Hendrix::Tune')

        Hendrix.lyrics[name] = base
      end

      # Return the module namespace from an Extension subclass
      #
      # Cnfs::Aws::Plugin => :aws
      # Test::Application => :application
      #
      def name_from_base(base) = base.name.to_s.split('::')[1].downcase.to_sym
    end

    def config() = @config ||= Lyric::Configuration.new
  end
end
