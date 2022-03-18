# frozen_string_literal: true

module SolidApp
  class Extension
    class << self
      def before_configuration() = @before_configuration ||= []
      def before_initialize() = @before_initialize ||= []
      def before_eager_load() = @before_eager_load ||= []
      def after_initialize() = @after_initialize ||= []

      def initialize! # rubocop:disable Metrics/AbcSize
        # First configurable block to run. Called before any initializers are run.
        before_configuration.each { |blk| blk.call(SolidApp.config) }

        # Second configurable block to run. Called before frameworks initialize.
        before_initialize.each { |blk| blk.call(SolidApp.config) }

        # Run each extension's initializers; Initialziers do not have access to plugin classes
        SolidApp.extensions.values.each do |extension|
          extension.config.initializers.each { |init| init[:block].call(SolidApp.config) }
          extension.initializer_files.each { |file| require file }
        end

        # Third configurable block to run; Still don't have access to classes in app
        before_eager_load.each { |blk| blk.call(SolidApp.config) }

        yield

        # Last configurable block to run. Called after frameworks initialize.
        # Here have access to all classes in app
        after_initialize.each { |blk| blk.call(SolidApp.config) }
      end
    end

    class Configuration
      # Record initializers to be run after the application has loaded
      def initializers() = @initializers ||= []

      # First configurable block to run. Called before any initializers are run.
      def before_configuration(&block)
        SolidApp::Extension.before_configuration << block if block
      end

      # Second configurable block to run. Called before frameworks initialize.
      def before_initialize(&block)
        SolidApp::Extension.before_initialize << block if block
      end

      # Third configurable block to run
      def before_eager_load(&block)
        SolidApp::Extension.before_eager_load << block if block
      end

      # Last configurable block to run. Called after frameworks initialize.
      def after_initialize(&block)
        SolidApp::Extension.after_initialize << block if block
      end

      def initialize(**options) = @configurations = options

      # Reused from railties/lib/rails/application/configuration.rb
      def method_missing(method, *args)
        return if %i[after_initialize after_user_config].include?(method)

        if method.end_with?('=')
          @configurations[:"#{method[0..-2]}"] = args.first
        else
          @configurations.fetch(method) do
            @configurations[method] = ActiveSupport::OrderedOptions.new
          end
        end
      end

      def respond_to_missing?(_symbol, *) = true
    end
  end
end
