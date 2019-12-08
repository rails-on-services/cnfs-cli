# frozen_string_literal: true

module App::Backend
  class DestroyController < Cnfs::Command
    attr_accessor :options, :platform

    before_execute :echo
    after_execute :echo_after

    # TODO: Use a method that returns a Cnfs::Core::Platform class rather than direct access to Cnfs.platform
    # so that any instance of that class can be returned
    def initialize(options, platform = Cnfs.platform)
      @options = options
      @platform = platform
      type = :compose
      self.class.include(self.class.registrations[type]) if self.class.registrations[type]
    end

    def echo; output.puts 'hello from cli gem' end

    # def execute_command(args) # (input: $stdin, output: $stdout)
    #   generator_name.gsub('Destroy', 'Deploy').constantize.new(
    #     [], { values: platform.application.backend }, { behavior: :revoke }
    #   ).invoke_all
    #   output.puts 'DESTROY OK'
    # end

    def echo_after; output.puts 'goodbye from cli gem' end
#   end
# end
# # frozen_string_literal: true
# 
# module Cnfs::Commands::Application
#   class Backend::Destroy < Cnfs::Command
#     module Compose
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
# end
