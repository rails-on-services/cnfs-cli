# frozen_string_literal: true

module Cnfs::Commands::Application
  class Backend::Destroy < Cnfs::Command
    module Compose
      def self.included(base)
        base.before_validate :set_compose_options
      end

      def set_compose_options
        @compose_options = ''
        if options.daemon or options.console or options.shell or options.attach
          @compose_options = '-d'
        end
        output.puts "compose options set to #{@compose_options}" if options.verbose
      end
    end
  end
end
