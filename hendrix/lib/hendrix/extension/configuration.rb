# frozen_string_literal: true

module Hendrix
  class Lyric 
    class << self
      def before_configuration() = @before_configuration ||= []
      def before_initialize() = @before_initialize ||= []
      def before_eager_load() = @before_eager_load ||= []
      def after_initialize() = @after_initialize ||= []
    end

    class Configuration
      def initialize() = @@options ||= {}

      # First configurable block to run. Called before any initializers are run.
      def before_configuration(&block)
        Hendrix::Lyric.before_configuration << block if block
      end

      # Second configurable block to run. Called before frameworks initialize.
      def before_initialize(&block)
        Hendrix::Lyric.before_initialize << block if block
      end

      # Third configurable block to run
      def before_eager_load(&block)
        Hendrix::Lyric.before_eager_load << block if block
      end

      # Last configurable block to run. Called after frameworks initialize.
      def after_initialize(&block)
        Hendrix::Lyric.after_initialize << block if block
      end

      def initialize(**options)
        @configurations = options
        # after_initialize
      end

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
