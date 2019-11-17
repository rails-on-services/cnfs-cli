# frozen_string_literal: true

module Cnfs::Core
  module Generators::Application::Backend
    class Deploy < Thor::Group
      include Cnfs::Core::Concerns::Generator

      def self.source_paths; a_source_paths end

      def setup
        @values = options[:values]
      end

      def compose_env
        return unless type.eql?(:compose)
        g = ComposeEnv.new(args, options, { behavior: behavior })
        g.invoke_all
      end

      # TODO: Figure out how to call the generator for each of these resources
      # What about which ones are active and skipping those that are not?
      def resources
        values.resources.each do |resource|
          # resource.generate
        end
      end

      private

      def type
        keys = values.parent.parent.infra.settings.keys
        keys.include?(:instance) ? :compose : keys.include?(:kubernetes) ? :skaffold : nil
      end

      def generate
        # args, options, config
        # g = ComposeEnv.new([], { values: self }, { behavior: :revoke })
        # g.invoke_all

        g = Generator.new([], { values: self })
        g.invoke_all
        nil
      end
    end
  end
end
