# frozen_string_literal: true

# Extensions provide the core of the Framework
module SolidSupport
  class << self
    def extensions() = @extensions ||= {}

    # Record initializers to be run after the application has loaded
    # def initializers() = @initializers ||= []
  end

  class Extension
    ABSTRACT_EXTENSIONS = %w[SolidSupport::Extension SolidSupport::Plugin SolidSupport::Application].freeze

    class << self
      delegate :config, to: :instance

      def abstract_extension?(name) = ABSTRACT_EXTENSIONS.include?(name.to_s)

      def instance() = @instance ||= new

      def initializer_files() = initializers_path.exist? ? initializers_path.glob('**/*.rb') : []

      def initializers_path() = config_path.join('initializers')

      def config_path() = gem_root.join('config')

      def app_path() = gem_root.join('app')

      def root() = gem_root

      # Called one or more times by subclasses to execute a block of code after application initialization
      def initializer(init_name, &block)
        yield config
        config.initializers.append({ init_name: init_name, block: block })
      end

      def inherited(base)
        return if abstract_extension?(base)

        SolidSupport.extensions[base.to_s] = base
        super
      end
    end

    def config() = @config ||= Extension::Configuration.new
  end
end
